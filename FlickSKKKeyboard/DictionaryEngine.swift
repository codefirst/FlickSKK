// SKKの辞書をラップして、フリック入力に適したインターフェースを提供する
class DictionaryEngine {
    private let dictionary : SKKDictionary
    init(dictionary : SKKDictionary){
        self.dictionary = dictionary
    }

    // 変換結果を学習する
    func learn(kana : String, okuri : String?, kanji : String) {
        // 正規化する
        let (k, o) = normalize(kana, okuri: okuri)

        // 学習する
        self.dictionary.learn(k, okuri: o, kanji: kanji)
    }

    // 辞書を検索する。
    //  ・ っの特殊ルール等を考慮する
    func find(kana : String, okuri : String?) -> [String] {
        // 正規化する
        let (t, roman) = normalize(kana, okuri: okuri)

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

    // 変換結果を登録する
    func register(kana : String, okuri : String?, kanji : String) {
        // 正規化する
        let (k, o) = normalize(kana, okuri: okuri)

        // 辞書登録
        dictionary.register(k, okuri: o, kanji: kanji)

    }

    // SKK辞書用に正規化する
    private func normalize(kana : String, okuri : String?) -> (String, String?) {
        // 読みをひらかなにする
        let t = kana.conv(.Hirakana)

        // 送り仮名をローマ字に変換する
        let roman : String? = okuri?.first()?.toRoman()?.first().map({ c in String(c) })

        return (t, roman)
    }
}