enum Candidate : Equatable {
    case Abbrev(kanji: String, kana: String)
    case Original(kanji : String)
}

func ==(l : Candidate, r : Candidate) -> Bool {
    switch (l,r)  {
    case let (.Abbrev(kanji: kanji1, kana: kana1), .Abbrev(kanji: kanji2, kana: kana2)):
        return kanji1 == kanji2 && kana1 == kana2
    case let (.Original(kanji: kanji1), .Original(kanji: kanji2)):
        return kanji1 == kanji2
    default:
        return false
    }
}
