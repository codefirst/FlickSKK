// トップレベルと、単語登録モードではテキストの挿入先が異なる。
// そこを抽象化する。

class TextEngine {
    enum Status {
        // トップレベルのため、iOS側にテキストの追加・削除を伝える
        case TopLevel
        // 単語登録モード内のため、仮想的なエリアでテキストの追加・削除をする
        case Compose(text : String, update : (String) -> Void)
    }

    private let dictionary : DictionaryEngine
    private let delegate : SKKDelegate

    init(delegate : SKKDelegate, dictionary : DictionaryEngine) {
        self.delegate = delegate
        self.dictionary = dictionary
    }

    // テキストを確定させる。 learnを指定していれば、変換結果の学習も行なう。
    func insert(text : String, learn : (String, String?)?, status : Status) -> Status {
        if let (kana, okuri) = learn {
            if okuri == nil {
                self.dictionary.learn(kana, okuri: okuri, kanji: text)
            } else {
                // 送り仮名がある場合、textは送り仮名付きになっている。
                // 辞書には送り仮名以外の部分を登録する必要がある。
                self.dictionary.learn(kana, okuri: okuri, kanji: text.butLast())
            }
        }
        return insertText(text, status : status)
    }

    // 最後の一文字を消す
    func deleteBackward(status : Status) {
        switch status {
        case .TopLevel:
            self.delegate.deleteBackward()
        case .Compose(text: let text, update: let update):
            let s = text.butLast()
            update(s)
        }
    }

    // 最後と一文字を濁点にする
    func toggleDakuten(beforeText : String, status : Status) {
        switch status {
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
    }

    // 最後と一文字を大文字にする
    func toggleUpperLower(beforeText : String, status : Status) {
        switch status {
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
    }

    private func insertText(text : String, status : Status) -> Status {
        switch status {
        case .TopLevel:
            self.delegate.insertText(text)
            return .TopLevel
        case .Compose(text: let prev, update: let update):
            update(prev + text)
            return .Compose(text: prev + text, update: update)
        }
    }
}

