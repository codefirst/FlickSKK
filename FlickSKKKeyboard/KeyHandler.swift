// キー入力を受け取り、次の状態を返す。
// その際、状態に応じて、テキストの追加・削除を行なう
class KeyHandler {
    private weak var delegate : SKKDelegate?
    private let dictionary : DictionaryEngine
    private let text : TextEngine
    private let factory : ComposeModeFactory

    init(delegate : SKKDelegate, dictionary : SKKDictionary) {
        self.delegate = delegate
        self.dictionary = DictionaryEngine(dictionary: dictionary)
        self.text = TextEngine(delegate: delegate, dictionary: self.dictionary)
        self.factory = ComposeModeFactory(dictionary: self.dictionary)
    }

    func handle(keyEvent : SKKKeyEvent, composeMode : ComposeMode) -> ComposeMode {
        return dispatch(keyEvent, composeMode: composeMode, status: .TopLevel)
    }

    // 現在の状態に応じて、適切なメソッドを呼び分ける
    private func dispatch(keyEvent: SKKKeyEvent, composeMode: ComposeMode, status: TextEngine.Status) -> ComposeMode {
        switch composeMode {
        case .DirectInput:
            return directInput(keyEvent, status: status) ?? composeMode
        case .KanaCompose(kana: let kana, candidates: let candidates):
            return kanaCompose(keyEvent, kana: kana, candidates: candidates, status: status) ?? composeMode
        case .KanjiCompose(kana: let kana, okuri: let okuri, candidates: let candidates, index : let index):
            return kanjiCompose(keyEvent,
                kana: kana, okuri: okuri, candidates: candidates, index: index,
                status: status) ?? composeMode
        case .WordRegister(kana: let kana, okuri: let okuri, composeText: let composeText, composeMode: let m):
            return wordRegister(keyEvent,
                kana: kana, okuri: okuri, composeText: composeText, composeMode: m[0],
                status: status) ?? composeMode
        }
    }

    // 通常モード
    private func directInput(keyEvent : SKKKeyEvent, status : TextEngine.Status) -> ComposeMode? {
        switch keyEvent {
        case .Char(kana: let kana, shift : let shift) where !shift:
            text.insert(kana, learn: nil, status: status)
        case .Char(kana: let kana, shift : _): // shiftが押されている
            return factory.kanaCompose(kana)
        case .Space:
            text.insert(" ", learn: nil, status: status)
        case .Enter:
            text.insert("\n", learn: nil, status: status)
        case .Backspace:
            text.deleteBackward(status)
        case .ToggleDakuten(beforeText : let beforeText):
            text.toggleDakuten(beforeText, status: status)
        case .ToggleUpperLower(beforeText: let beforeText):
            text.toggleUpperLower(beforeText, status : status)
        case .InputModeChange(inputMode: let inputMode):
            self.delegate?.changeInputMode(inputMode)
        case .Select(_):
            break
        case .SkipPartialCandidates:
            break
        }
        return nil
    }

    // ▽モード
    private func kanaCompose(keyEvent : SKKKeyEvent, kana : String, candidates: [Candidate], status: TextEngine.Status) -> ComposeMode? {
        switch keyEvent {
        case .Char(kana: let str, shift : let shift) where !shift:
            return factory.kanaCompose(kana + str)
        case .Char(kana: let str, shift : _): // shiftが押されている
            return factory.kanjiCompose(kana, okuri: str)
        case .Space:
            return factory.kanjiCompose(kana, okuri: .None)
        case .Enter:
            // かなモードでのEnterは学習しない
            text.insert(kana, learn: nil, status: status)
            return .DirectInput
        case .Backspace:
            let str = kana.butLast()

            if str.isEmpty {
                return .DirectInput
            } else {
                return factory.kanaCompose(str)
            }
        case .ToggleDakuten(beforeText : _):
            if let s = kana.last()?.toggleDakuten() {
                return factory.kanaCompose(kana.butLast() + s)
            } else {
                return nil
            }
        case .ToggleUpperLower(beforeText: _):
            if let s = kana.last()?.toggleUpperLower() {
                return factory.kanaCompose(kana.butLast() + s)
            } else {
                return nil
            }
        case .InputModeChange(inputMode: let inputMode):
            let str = kana.conv(inputMode.kanaType())
            text.insertPartial(str, kana: kana, status: status)
            return .DirectInput
        case .Select(index: let index):
            if index < candidates.count {
                text.insertCandidate(candidates[index], learn: (kana, nil), status : status)
                return .DirectInput
            } else {
                return .WordRegister(kana : kana, okuri : .None, composeText: "", composeMode : [ .DirectInput ])
            }
        case .SkipPartialCandidates:
            let nextMode = factory.kanjiCompose(kana, okuri: .None)
            switch nextMode {
            case let .KanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: index):
                if let index = candidates.index({!$0.isPartial}) {
                    return .KanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: index)
                }
                return nextMode
            default:
                return nextMode
            }
        }
    }

    // ▼モード
    private func kanjiCompose(keyEvent : SKKKeyEvent,
        kana : String, okuri : String?, candidates : [Candidate], index : Int,
        status : TextEngine.Status) -> ComposeMode? {
        switch keyEvent {
        case .Char(kana: let str, shift : let shift):
            // 暗黙的に確定する。単語登録中の場合は、statusが更新されるので、次に引き渡す
            let status = text.insertCandidate(candidates[index], learn: (kana, okuri), status : status)
            // 次の処理を開始する
            return self.dispatch(keyEvent, composeMode: .DirectInput, status: status)
        case .Space:
            if index + 1 < candidates.count {
                return .KanjiCompose(kana : kana, okuri : okuri, candidates: candidates, index: index + 1)
            } else {
                return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
            }
        case .Enter:
            text.insertCandidate(candidates[index], learn: (kana, okuri), status : status)
            return .DirectInput
        case .Backspace where index == 0:
            return factory.kanaCompose(kana)
        case .Backspace:
            return .KanjiCompose(kana : kana, okuri : .None, candidates: candidates, index: index - 1)
        case .ToggleDakuten(beforeText : _):
            if let okuri = okuri?.toggleDakuten() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case .ToggleUpperLower(beforeText: _):
            if let okuri = okuri?.toggleUpperLower() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case .InputModeChange(inputMode: let inputMode):
            self.delegate?.changeInputMode(inputMode)
            return nil
        case .Select(index : let index):
            if index < candidates.count {
                text.insertCandidate(candidates[index], learn: (kana, okuri), status : status)
                return .DirectInput
            } else {
                return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
            }
        case .SkipPartialCandidates:
            var nextIndex = index + 1
            if let exactIndex = candidates.index({!$0.isPartial}) {
                nextIndex = max(nextIndex, exactIndex)
            }
            
            if nextIndex < candidates.count {
                return .KanjiCompose(kana : kana, okuri : okuri, candidates: candidates, index: nextIndex)
            } else {
                return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
            }
        }
    }

    // 単語登録モード
    private func wordRegister(keyEvent : SKKKeyEvent,
        kana : String, okuri: String?, composeText: String, composeMode: ComposeMode,
        status : TextEngine.Status) -> ComposeMode? {
        switch (composeMode, keyEvent) {
        case (.DirectInput, .Enter):
            // 辞書登録
            dictionary.register(kana, okuri: okuri, kanji: composeText)

            // composeTextを入力する
            text.insert(composeText + (okuri ?? ""), learn: (kana, okuri), status: status)

            // 状態遷移
            return .DirectInput
        case (.DirectInput, .Backspace) where composeText.isEmpty:
            // 先頭でバックスペース押した場合は、▽モードに戻る
            return factory.kanaCompose(kana)
        case (.DirectInput, .ToggleDakuten(_)) where composeText.isEmpty:
            // 先頭で濁点トグルしたら、再変換する
            if let okuri = okuri?.toggleDakuten() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case (.DirectInput, .ToggleUpperLower(_)) where composeText.isEmpty:
            // 先頭で大文字・小文字トグルしたら、再変換する
            if let okuri = okuri?.toggleUpperLower() {
                return factory.kanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        default:
            // それ以外のキーは再帰的に処理する
            var text = composeText
            let m = dispatch(keyEvent, composeMode: composeMode, status: .Compose(text: text, update: { str in
                text = str
            }))
            return .WordRegister(kana: kana, okuri: okuri, composeText: text, composeMode: [m])
        }
    }
}
