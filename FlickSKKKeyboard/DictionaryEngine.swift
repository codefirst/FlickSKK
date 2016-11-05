// SKKの辞書をラップして、フリック入力に適したインターフェースを提供する
class DictionaryEngine {
    fileprivate let dictionary : SKKDictionary
    init(dictionary : SKKDictionary){
        self.dictionary = dictionary
    }

    // 変換結果を学習する
    func learn(_ kana : String, okuri : String?, kanji : String) {
        // 正規化する
        let (k, o) = normalize(kana, okuri: okuri)

        // 学習する
        self.dictionary.learn(k, okuri: o, kanji: kanji)
    }

    // q-確定の結果を学習する
    func partial(_ kana: String, kanji: String) {
        // 正規化する
        let (k, _) = normalize(kana, okuri: nil)

        // 学習する
        self.dictionary.partial(k, okuri: nil, kanji: kanji)
    }

    // 辞書を検索する。
    //  ・ っの特殊ルール等を考慮する
    func find(_ kana : String, okuri : String?, dynamic: Bool) -> [Candidate] {
        // 結果をストアする
        var candidates : [Candidate] = []

        // 正規化する
        let (t, roman) = normalize(kana, okuri: okuri)

        // ダイナミック変換
        if dynamic {
            for candidate in self.dictionary.findDynamic(kana) {
                candidates.append(.partial(kanji: candidate.kanji, kana: candidate.kana))
            }
        }

        // 通常の検索をする
        for candidate in self.dictionary.find(t, okuri: roman) {
            candidates.append(.exact(kanji: candidate + (okuri ?? "")))
        }

        // 末尾が「っ」の場合は、変換位置を1つ前にする
        if okuri != .none && t.last() == "っ" {
            // 「っ」送り仮名の場合の特殊処理
            // https://github.com/codefirst/FlickSKK/issues/27
            for candidate in self.dictionary.find(t.butLast(), okuri: roman) {
                candidates.append(.exact(kanji: candidate + "っ" + (okuri ?? "")))
            }
        }
        return candidates
    }

    // 変換結果を登録する
    func register(_ kana : String, okuri : String?, kanji : String) {
        // 正規化する
        let (k, o) = normalize(kana, okuri: okuri)

        // 辞書登録
        dictionary.register(k, okuri: o, kanji: kanji)

    }

    // SKK辞書用に正規化する
    fileprivate func normalize(_ kana : String, okuri : String?) -> (String, String?) {
        // 読みをひらかなにする
        let t = kana.conv(.hirakana)

        // 送り仮名をローマ字に変換する
        let roman : String? = okuri?.first()?.toRoman()?.first().map({ c in String(c) })

        return (t, roman)
    }
}
