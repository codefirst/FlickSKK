class ComposeModeFactory {
    private let dictionary : DictionaryEngine

    init(dictionary : DictionaryEngine) {
        self.dictionary = dictionary
    }

    func kanaCompose(kana : String) -> ComposeMode {
        return .KanaCompose(kana : kana, candidates: dictionary.find(kana, okuri: nil))
    }

    func kanjiCompose(kana : String, okuri : String?) -> ComposeMode {
        let candidates = dictionary.find(kana, okuri: okuri)
        if candidates.isEmpty {
            return .WordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .DirectInput ])
        } else {
            return .KanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: 0)
        }
    }
}