class EntryParser {
    private let entry : String

    init(entry : String) {
        self.entry = entry
    }

    // 登録されている単語一覧を取得
    func words() -> [String] {
        let xs = self.entry.pathComponents
        if xs.count <= 2 {
            return []
        } else {
            return Array(xs[1...xs.count-2]).map { x in self.unescape(x) }
        }
    }

    // 単語を追加
    func append(word : String) -> String {
        let xs = words()
        if contains(xs, word) {
            return self.entry
        } else {
            return join([ word ] + xs)
        }
    }

    // 単語の削除
    func remove(word : String) -> String? {
        let xs = words().filter({ x in
            x != word
        })

        if xs.isEmpty {
            return nil
        } else {
            return join(xs)
        }
    }

    // 単語リストを結合して、SKKのエントリにする
    //  ["a", "b"] => /a/b/
    private func join(xs : [String]) -> String {
        return xs.reduce("", {(x,y) in x + "/" + self.escape(y) }) + "/"
    }

    // 特殊な文字は置換する。
    // 置換方式はSKKによって違うが、ここではAquaSKKと同様に[xx]に置換する方式を取る。
    private let EscapeStrings = [("[","[5b]"), ("/", "[2f]"), (";","[3b]")]

    private func escape(str : String) -> String {
        return EscapeStrings.reduce(str) { (str, x) in
            let (from, to) = x
            return str.stringByReplacingOccurrencesOfString(from, withString: to, options: nil, range: nil)
        }
    }

    private func unescape(str : String) -> String {
        return EscapeStrings.reduce(str) { (str, x) in
            let (from, to) = x
            return str.stringByReplacingOccurrencesOfString(to, withString: from, options: nil, range: nil)
        }
    }
}
