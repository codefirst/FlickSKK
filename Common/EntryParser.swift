// SKK辞書の各エントリをパースする。
//
// SKKの各エントリは以下のようになっている。
//
//   わb /詫;謝罪する/侘;侘び寂び/
//
// ここから、「詫」「侘」を取り出す。
//
// この際、以下の処理を行なう。
//
//  - 現在、サポートされていないため、アノテーションを除去する
//  - "/" といった登録できない文字のエスケープ解除
class EntryParser {
    private let entry : String

    init(entry : String) {
        self.entry = entry
    }

    func title() -> String? {
        if let n = self.entry.characters.indexOf(" ") {
            return self.entry.substringToIndex(n)
        } else {
            return nil
        }
    }

    // 登録されている単語一覧を取得
    func words() -> [String] {
        return rawWords().map {
            self.unescape(self.stripAnnotation($0))
        }
    }

    // 単語を追加
    func append(word : String) -> String {
        let xs = words().filter({ x in
            x != word
        })
        return join([ word ] + xs)
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
        return xs.reduce("", combine: {(x,y) in x + "/" + self.escape(y) }) + "/"
    }

    // 特殊な文字は置換する。
    // 置換方式はSKKによって違うが、ここではAquaSKKと同様に[xx]に置換する方式を取る。
    private let EscapeStrings = [("[","[5b]"), ("/", "[2f]"), (";","[3b]")]

    private func escape(str : String) -> String {
        return EscapeStrings.reduce(str) { (str, x) in
            let (from, to) = x
            return str.stringByReplacingOccurrencesOfString(from, withString: to, options: [], range: nil)
        }
    }

    // 単語ごとに分割する
    func rawWords() -> [String] {
        let xs = self.entry.componentsSeparatedByString("/")
        if xs.count <= 2 {
            return []
        } else {
            return Array(xs[1...xs.count-2])
        }
    }

    // エスケープの解除
    private func unescape(str : String) -> String {
        return EscapeStrings.reduce(str) { (str, x) in
            let (from, to) = x
            return str.stringByReplacingOccurrencesOfString(to, withString: from, options: [], range: nil)
        }
    }

    // アノテーションの除去
    private func stripAnnotation(str : String) -> String {
        if let index = str.characters.indexOf(";") {
            return str.substringToIndex(index)
        } else {
            return str
        }
    }
}
