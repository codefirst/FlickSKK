enum Candidate : Equatable {
    case partial(kanji: String, kana: String)
    case exact(kanji : String)

    var kanji: String {
        switch self {
        case .partial(kanji: let kanji, kana: _): return kanji
        case .exact(kanji: let kanji): return kanji
        }
    }

    var isPartial: Bool {
        switch self {
        case .partial(kanji: _, kana: _): return true
        default: return false
        }
    }
}

func ==(l : Candidate, r : Candidate) -> Bool {
    switch (l,r)  {
    case let (.partial(kanji: kanji1, kana: kana1), .partial(kanji: kanji2, kana: kana2)):
        return kanji1 == kanji2 && kana1 == kana2
    case let (.exact(kanji: kanji1), .exact(kanji: kanji2)):
        return kanji1 == kanji2
    default:
        return false
    }
}
