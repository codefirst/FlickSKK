enum KeyboardMode: Hashable {
    case InputMode(mode : SKKInputMode)
    case Number
    case Alphabet

    var hashValue: Int {
        switch self {
        case .InputMode(_): return 0
        case .Number: return 1
        case .Alphabet: return 2
        }
    }
}

func ==(l : KeyboardMode, r : KeyboardMode) -> Bool {
    switch (l,r)  {
    case let (.InputMode(m), .InputMode(n)): return m == n
    default: return l.hashValue == r.hashValue
    }
}