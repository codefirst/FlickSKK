class ComposeModeFactory {
    fileprivate let dictionary : DictionaryEngine

    init(dictionary : DictionaryEngine) {
        self.dictionary = dictionary
    }

    func kanaCompose(_ kana : String) -> ComposeMode {
        let candidates = dictionary.find(kana, okuri: nil, dynamic: kana.utf16.count > 1)
        return .kanaCompose(kana : kana, candidates: candidates)
    }

    func kanjiCompose(_ kana : String, okuri : String?) -> ComposeMode {
        let candidates = dictionary.find(kana, okuri: okuri, dynamic: okuri == nil && kana.utf16.count > 1)
        if candidates.isEmpty {
            return .wordRegister(kana : kana, okuri : okuri, composeText: "", composeMode : [ .directInput ])
        } else {
            return .kanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: 0)
        }
    }
}
