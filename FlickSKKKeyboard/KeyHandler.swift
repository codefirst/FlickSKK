// キー入力を受け取り、次の状態を返す。
// その際、状態に応じて、テキストの追加・削除を行なう
class KeyHandler {
    private weak var delegate : SKKDelegate!
    private let dictionary : SKKDictionary

    private enum Level {
        // トップレベルのため、iOS側にテキストの追加・削除を伝える
        case TopLevel
        // 単語登録モード内のため、仮想的なエリアでテキストの追加・削除をする
        case Compose(text : String, update : (String) -> Void)
    }

    init(delegate : SKKDelegate, dictionary : SKKDictionary) {
        self.delegate = delegate
        self.dictionary = dictionary
    }

    func handle(keyEvent : SKKKeyEvent, composeMode : ComposeMode) -> ComposeMode {
        return dispatch(keyEvent, composeMode: composeMode, level: .TopLevel)
    }

    private func dispatch(keyEvent: SKKKeyEvent, composeMode: ComposeMode, level: Level) -> ComposeMode {
        switch composeMode {
        case .DirectInput:
            return directInput(keyEvent, level: level) ?? composeMode
        case .KanaCompose(kana: let kana, candidates: let candidates):
            return kanaCompose(keyEvent, kana: kana, candidates: candidates, level: level) ?? composeMode
        case .KanjiCompose(kana: let kana, okuri: let okuri, candidates: let candidates, index : let index):
            return kanjiCompose(keyEvent,
                kana: kana, okuri: okuri, candidates: candidates, index: index,
                level: level) ?? composeMode
        case .WordRegister(kana: let kana, okuri: let okuri, composeText: let composeText, composeMode: let m):
            return wordRegister(keyEvent,
                kana: kana, okuri: okuri, composeText: composeText, composeMode: m[0],
                level: level) ?? composeMode
        }
    }

    private func directInput(keyEvent : SKKKeyEvent, level: Level) -> ComposeMode? {
        switch keyEvent {
        case .Char(kana: let kana, shift : let shift) where !shift:
            insertText(kana, level: level)
        case .Char(kana: let kana, shift : _): // shiftが押されている
            return makeKanaCompose(kana)
        case .Space:
            insertText(" ", level: level)
        case .Enter:
            switch level {
            case .TopLevel:
                self.delegate.insertText("\n")
            case .Compose(text: _, update: let update):
                update("Please report bug case")
            }
        case .Backspace:
            switch level {
            case .TopLevel:
                self.delegate.deleteBackward()
            case .Compose(text: let text, update: let update):
                update(text.butLast())
            }
        case .ToggleDakuten(beforeText : let beforeText):
            switch level {
            case .TopLevel:
                if let s = beforeText.last()?.toggleDakuten() {
                    self.delegate.deleteBackward()
                    self.delegate.insertText(s)
                }
            case .Compose(text: let text, update: let update):
                if let s = text.last()?.toggleDakuten() {
                    update(text.butLast() + s)
                }
            }
        case .ToggleUpperLower(beforeText: let beforeText):
            switch level {
            case .TopLevel:
                if let s = beforeText.last()?.toggleUpperLower() {
                    self.delegate.deleteBackward()
                    self.delegate.insertText(s)
                }
            case .Compose(text: let text, update: let update):
                if let s = text.last()?.toggleUpperLower() {
                    update(text.butLast() + s)
                }
            }
        case .InputModeChange(inputMode: let inputMode):
            self.delegate.changeInputMode(inputMode)
        case .Select(_):
            ()
        }
        return nil
    }

    private func makeKanaCompose(kana : String) -> ComposeMode {
        return .KanaCompose(kana : kana, candidates: consult(kana, okuri: .None))
    }

    private func makeKanjiCompose(kana : String, okuri : String?) -> ComposeMode {
        let candidates = consult(kana, okuri: okuri)
        if candidates.isEmpty {
            return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
        } else {
            return .KanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: 0)
        }
    }

    private func kanaCompose(keyEvent : SKKKeyEvent, kana : String, candidates: [String], level: Level) -> ComposeMode? {
        switch keyEvent {
        case .Char(kana: let str, shift : let shift) where !shift:
            return makeKanaCompose(kana + str)
        case .Char(kana: let str, shift : _): // shiftが押されている
            return makeKanjiCompose(kana, okuri: str)
        case .Space:
            return makeKanjiCompose(kana, okuri: .None)
        case .Enter:
            // かなモードでのEnterは学習しない
            insertText(kana, level: level)
            return .DirectInput
        case .Backspace where kana.isEmpty:
            return .DirectInput
        case .Backspace:
            return makeKanaCompose(kana.butLast())
        case .ToggleDakuten(beforeText : _):
            if let s = kana.last()?.toggleDakuten() {
                return makeKanaCompose(kana.butLast() + s)
            } else {
                return nil
            }
        case .ToggleUpperLower(beforeText: _):
            if let s = kana.last()?.toggleUpperLower() {
                return makeKanaCompose(kana.butLast() + s)
            } else {
                return nil
            }
        case .InputModeChange(inputMode: let inputMode):
            let str = kana.conv(kanaType(inputMode))
            insertText(str, level: level)
            return .DirectInput
        case .Select(index: let index):
            if index < candidates.count {
                decide(kana, okuri : .None, text: candidates[index], level: level)
                return .DirectInput
            } else {
                return .WordRegister(kana : kana, okuri : .None, composeText: "", composeMode : [ .DirectInput ])
            }
        }
    }

    private func kanjiCompose(keyEvent : SKKKeyEvent,
        kana : String, okuri : String?, candidates : [String], index : Int,
        level : Level) -> ComposeMode? {
        switch keyEvent {
        case .Char(kana: let str, shift : let shift):
            // 暗黙的に確定する。単語登録中の場合は、levelが更新されるので、次に引き渡す
            let level = decide(kana, okuri: okuri, text: candidates[index], level: level)
            // 次の処理を開始する
            return self.dispatch(keyEvent, composeMode: .DirectInput, level: level)
        case .Space:
            if index + 1 < candidates.count {
                return .KanjiCompose(kana : kana, okuri : .None, candidates: candidates, index: index + 1)
            } else {
                return .WordRegister(kana : kana, okuri : .None, composeText: "", composeMode : [ .DirectInput ])
            }
        case .Enter:
            insertText(candidates[index], level: level)
            return .DirectInput
        case .Backspace where index == 0:
            return makeKanaCompose(kana)
        case .Backspace:
            return .KanjiCompose(kana : kana, okuri : .None, candidates: candidates, index: index - 1)
        case .ToggleDakuten(beforeText : _):
            if let okuri = okuri?.toggleDakuten() {
                return makeKanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case .ToggleUpperLower(beforeText: _):
            if let okuri = okuri?.toggleUpperLower() {
                return makeKanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case .InputModeChange(inputMode: let inputMode):
            self.delegate.changeInputMode(inputMode)
            return nil
        case .Select(index : let index):
            if index < candidates.count {
                decide(kana, okuri: okuri, text: candidates[index], level: level)
                return .DirectInput
            } else {
                return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
            }
        }
    }

    private func decide(kana : String, okuri : String?, text : String, level : Level) -> Level {
        self.dictionary.learn(kana, okuri: okuri, kanji: text)
        return insertText(text, level : level)
    }

    private func insertText(text : String, level : Level) -> Level {
        switch level {
        case .TopLevel:
            self.delegate.insertText(text)
            return .TopLevel
        case .Compose(text: let prev, update: let update):
            update(prev + text)
            return .Compose(text: prev + text, update: update)
        }
    }

    private func wordRegister(keyEvent : SKKKeyEvent,
        kana : String, okuri: String?, composeText: String, composeMode: ComposeMode,
        level : Level) -> ComposeMode? {
        switch (composeMode, keyEvent) {
        case (.DirectInput, .Enter):
            // 送り仮名はローマ字に変換する
            let okuriRoman = okuri?.first()?.toRoman()?.first().map({c in String(c)})

            // 辞書登録
            dictionary.register(kana, okuri: okuriRoman, kanji: composeText)

            // composeTextを入力する
            decide(kana, okuri : okuri, text: composeText + (okuri ?? ""), level: level)

            // 状態遷移
            return .DirectInput
        case (.DirectInput, .Backspace) where composeText.isEmpty:
            // 先頭でバックスペース押した場合は、▽モードに戻る
            return makeKanaCompose(kana)
        case (.DirectInput, .ToggleDakuten(_)) where composeText.isEmpty:
            // 先頭で濁点トグルしたら、再変換する
            if let okuri = okuri?.toggleDakuten() {
                return makeKanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        case (.DirectInput, .ToggleUpperLower(_)) where composeText.isEmpty:
            // 先頭で大文字・小文字トグルしたら、再変換する
            if let okuri = okuri?.toggleUpperLower() {
                return makeKanjiCompose(kana, okuri: okuri)
            } else {
                return nil
            }
        default:
            var text = composeText
            let m = dispatch(keyEvent, composeMode: composeMode, level: .Compose(text: text, update: { str in
                text = str
            }))
            return .WordRegister(kana: kana, okuri: okuri, composeText: text, composeMode: [m])
        }
    }

    private func kanaType(inputMode : SKKInputMode) -> KanaType {
        switch inputMode {
        case .Hirakana:
            return .Hirakana
        case .Katakana:
            return .Katakana
        case .HankakuKana:
            return .HankakuKana
        }
    }

    private func consult(text : String, okuri : String?) -> [String] {
        // 正規化する
        let t = text.conv(.Hirakana)

        // 送り仮名をローマ字に変換する
        let roman : String? = okuri?.first()?.toRoman()?.first().map({ c in String(c) })

        // 辞書を検索する
        var xs = self.dictionary.find(t, okuri: roman).map({ (x : String)  ->  String in
            return x + (okuri ?? "")
        })

        // 末尾が「っ」の場合は、変換位置を1つ前にする
        if okuri != .None && t.last() == "っ" {
            // 「っ」送り仮名の場合の特殊処理
            // https://github.com/codefirst/FlickSKK/issues/27
            let ys = self.dictionary.find(t.butLast(), okuri: roman).map({ (y : String)  ->  String in
                return y + "っ" + (okuri ?? "")
            })
            xs += ys
        }
        return xs
    }

}
