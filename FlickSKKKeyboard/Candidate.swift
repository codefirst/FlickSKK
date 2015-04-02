enum Candidate : Equatable {
    case Partial(kanji: String, kana: String)
    case Exact(kanji : String)
}

func ==(l : Candidate, r : Candidate) -> Bool {
    switch (l,r)  {
    case let (.Partial(kanji: kanji1, kana: kana1), .Partial(kanji: kanji2, kana: kana2)):
        return kanji1 == kanji2 && kana1 == kana2
    case let (.Exact(kanji: kanji1), .Exact(kanji: kanji2)):
        return kanji1 == kanji2
    default:
        return false
    }
}
