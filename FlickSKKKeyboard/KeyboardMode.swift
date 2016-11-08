enum KeyboardMode: Hashable {
    case inputMode(mode : SKKInputMode)
    case number
    case alphabet

    var hashValue: Int {
        switch self {
        case .inputMode(_): return 0
        case .number: return 1
        case .alphabet: return 2
        }
    }
}

func ==(l : KeyboardMode, r : KeyboardMode) -> Bool {
    switch (l,r)  {
    case let (.inputMode(m), .inputMode(n)): return m == n
    default: return l.hashValue == r.hashValue
    }
}
