// キー入力を受け取り、次の状態を返す。
// その際、状態に応じて、テキストの追加・削除を行なう
class KeyHandler {
    fileprivate weak var delegate : SKKDelegate?
    fileprivate let dictionary : DictionaryEngine
    fileprivate let text : TextEngine
    fileprivate let factory : ComposeModeFactory

    init(delegate : SKKDelegate, dictionary : SKKDictionary) {
        self.delegate = delegate
        self.dictionary = DictionaryEngine(dictionary: dictionary)
        self.text = TextEngine(delegate: delegate, dictionary: self.dictionary)
        self.factory = ComposeModeFactory(dictionary: self.dictionary)
    }

    func handle(_ keyEvent : SKKKeyEvent, composeMode : ComposeMode) -> ComposeMode {
        return dispatch(keyEvent, composeMode: composeMode, status: .topLevel)
    }

    // 現在の状態に応じて、適切なメソッドを呼び分ける
    fileprivate func dispatch(_ keyEvent: SKKKeyEvent, composeMode: ComposeMode, status: TextEngine.Status) -> ComposeMode {
        switch composeMode {
        case .directInput:
            return directInput(keyEvent, status: status) ?? composeMode
        case .kanaCompose(kana: let kana, candidates: let candidates):
            return kanaCompose(keyEvent, kana: kana, candidates: candidates, status: status) ?? composeMode
        case .kanjiCompose(kana: let kana, okuri: let okuri, candidates: let candidates, index : let index):
            return kanjiCompose(keyEvent,
                kana: kana, okuri: okuri, candidates: candidates, index: index,
                status: status) ?? composeMode
        case .wordRegister(kana: let kana, okuri: let okuri, composeText: let composeText, composeMode: let m):
            return wordRegister(keyEvent,
                kana: kana, okuri: okuri, composeText: composeText, composeMode: m[0],
                status: status) ?? composeMode
        }
    }

    // 通常モード
    fileprivate func directInput(_ keyEvent : SKKKeyEvent, status : TextEngine.Status) -> ComposeMode? {
        switch keyEvent {
        case .char(kana: let kana, shift : let shift) where !shift:
            text.insert(kana, learn: nil, status: status)
        case .char(kana: let kana, shift : _): // shiftが押されている
            return factory.kanaCompose(kana)
        case .space:
            text.insert(" ", learn: nil, status: status)
        case .enter:
            text.insert("\n", learn: nil, status: status)
        case .backspace:
            text.deleteBackward(status)
        case .toggleDakuten(beforeText : let beforeText):
            text.toggleDakuten(beforeText, status: status)
        case .toggleUpperLower(beforeText: let beforeText):
            text.toggleUpperLower(beforeText, status : status)
        case .inputModeChange(inputMode: let inputMode):
            self.delegate?.changeInputMode(inputMode)
        case .select(_):
            break
        case .skipPartialCandidates:
            break
        }
        return nil
    }

    // ▽モード
    fileprivate func kanaCompose(_ keyEvent : SKKKeyEvent, kana : String, candidates: [Candidate], status: TextEngine.Status) -> ComposeMode? {
        switch keyEvent {
        case .char(kana: let str, shift : let shift) where !shift:
            return factory.kanaCompose(kana + str)
        case .char(kana: let str, shift : _): // shiftが押されている
            return factory.kanjiCompose(kana, okuri: str)
        case .space:
            return factory.kanjiCompose(kana, okuri: .none)
        case .enter:
            // かなモードでのEnterは学習しない
            text.insert(kana, learn: nil, status: status)
            return .directInput
        case .backspace:
            let str = kana.butLast()

            if str.isEmpty {
                return .directInput
            } else {
                return factory.kanaCompose(str)
            }
        case .toggleDakuten(beforeText : _):
            if let s = kana.last()?.toggleDakuten() {
                return factory.kanaCompose(kana.butLast() + s)
            } else {
                return nil
            }
        case .toggleUpperLower(beforeText: _):
            if let s = kana.last()?.toggleUpperLower() {
                return factory.kanaCompose(kana.butLast() + s)
            } else {
                return nil
            }
        case .inputModeChange(inputMode: let inputMode):
            let str = kana.conv(inputMode.kanaType())
            text.insertPartial(str, kana: kana, status: status)
            return .directInput
        case .select(index: let index):
            if index < candidates.count {
                text.insertCandidate(candidates[index], learn: (kana, nil), status : status)
                return .directInput
            } else {
                return .wordRegister(kana : kana, okuri : .none, composeText: "", composeMode : [ .directInput ])
            }
        case .skipPartialCandidates:
            let nextMode = factory.kanjiCompose(kana, okuri: .none)
            switch nextMode {
            case let .kanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: _):
                if let index = candidates.index({!$0.isPartial}) {
                    return .kanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: index)
                }
                return nextMode
            default:
                return nextMode
            }
        }
    }

    // ▼モード
    fileprivate func kanjiCompose(_ keyEvent : SKKKeyEvent,
        kana : String, okuri : String?, candidates : [Candidate], index : Int,
        status : TextEngine.Status) -> ComposeMode? {
        switch keyEvent {
        case .char(kana: _, shift : _):
            // 暗黙的に確定する。単語登録中の場合は、statusが更新されるので、次に引き渡す
            let status = text.insertCandidate(candidates[index], learn: (kana, okuri), status : status)
            // 次の処理を開始する
            return self.dispatch(keyEvent, composeMode: .directInput, status: status)
        case .space:
            if index + 1 < candidates.count {
                return .kanjiCompose(kana : kana, okuri : okuri, candidates: candidates, index: index + 1)
            } else {
                return .wordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .directInput ])
            }
        case .enter:
            text.insertCandidate(candidates[index], learn: (kana, okuri), status : status)
            return .directInput
        case .backspace where index == 0:
            return factory.kanaCompose(kana)
        case .backspace:
            return .kanjiCompose(kana : kana, okuri : .none, candidates: candidates, index: index - 1)
        case .toggleDakuten(beforeText : _):
            if let okuri = okuri?.toggleDakuten() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case .toggleUpperLower(beforeText: _):
            if let okuri = okuri?.toggleUpperLower() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case .inputModeChange(inputMode: let inputMode):
            self.delegate?.changeInputMode(inputMode)
            return nil
        case .select(index : let index):
            if index < candidates.count {
                text.insertCandidate(candidates[index], learn: (kana, okuri), status : status)
                return .directInput
            } else {
                return .wordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .directInput ])
            }
        case .skipPartialCandidates:
            var nextIndex = index + 1
            if let exactIndex = candidates.index({!$0.isPartial}) {
                nextIndex = max(nextIndex, exactIndex)
            }

            if nextIndex < candidates.count {
                return .kanjiCompose(kana : kana, okuri : okuri, candidates: candidates, index: nextIndex)
            } else {
                return .wordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .directInput ])
            }
        }
    }

    // 単語登録モード
    fileprivate func wordRegister(_ keyEvent : SKKKeyEvent,
        kana : String, okuri: String?, composeText: String, composeMode: ComposeMode,
        status : TextEngine.Status) -> ComposeMode? {
        switch (composeMode, keyEvent) {
        case (.directInput, .enter):
            // 辞書登録
            dictionary.register(kana, okuri: okuri, kanji: composeText)

            // composeTextを入力する
            text.insert(composeText + (okuri ?? ""), learn: (kana, okuri), status: status)

            // 状態遷移
            return .directInput
        case (.directInput, .backspace) where composeText.isEmpty:
            // 先頭でバックスペース押した場合は、▽モードに戻る
            return factory.kanaCompose(kana)
        case (.directInput, .toggleDakuten(_)) where composeText.isEmpty:
            // 先頭で濁点トグルしたら、再変換する
            if let okuri = okuri?.toggleDakuten() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case (.directInput, .toggleUpperLower(_)) where composeText.isEmpty:
            // 先頭で大文字・小文字トグルしたら、再変換する
            if let okuri = okuri?.toggleUpperLower() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        default:
            // それ以外のキーは再帰的に処理する
            var text = composeText
            let m = dispatch(keyEvent, composeMode: composeMode, status: .compose(text: text, update: { str in
                text = str
            }))
            return .wordRegister(kana: kana, okuri: okuri, composeText: text, composeMode: [m])
        }
    }
}
