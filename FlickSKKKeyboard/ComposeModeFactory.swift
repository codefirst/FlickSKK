class ComposeModeFactory {
    private let dictionary : DictionaryEngine

    init(dictionary : DictionaryEngine) {
        self.dictionary = dictionary
    }

    func kanaCompose(kana : String) -> ComposeMode {
        let candidates = dictionary.find(kana, okuri: nil, dynamic: count(kana.utf16) > 1)
        return .KanaCompose(kana : kana, candidates: candidates)
    }

    func kanjiCompose(kana : String, okuri : String?) -> ComposeMode {
        let candidates = dictionary.find(kana, okuri: okuri, dynamic: okuri == nil && count(kana.utf16) > 1)
        if candidates.isEmpty {
            return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
        } else {
            return .KanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: 0)
        }
    }
}
