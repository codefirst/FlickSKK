enum KanaFlickKey: Hashable {
    case seq(String, showSeqs: Bool)
    case shift
    case `return`
    case backspace
    case keyboardChange
    case inputModeChange([SKKInputMode?])
    case number
    case alphabet
    case komojiDakuten
    case upperLower
    case space
    case nothing

    // メインの「あ」「A」「1」など
    var buttonLabel: String {
        switch self {
        case let .seq(s, _): return String(s[s.startIndex])
        case .shift: return "⇧"
        case .return: return "⏎"
        case .backspace: return "⌫"
        case .keyboardChange: return ""
        case .inputModeChange: return "かな"
        case .number: return "123"
        case .alphabet: return "ABC"
        case .komojiDakuten: return "小゛゜"
        case .upperLower: return "a/A"
        case .space: return "space"
        case .nothing: return ""
        }
    }

    // 残りの「←↓↑→」など
    var additionalButtonLabel: String? {
        switch self {
        case let .seq(s, true):
            let seq = Array(s).map{String($0)}
            let left = seq.count > 1 ? seq[1] : " "
            let top = seq.count > 2 ? seq[2] : " "
            let right = seq.count > 3 ? seq[3] : " "
            let bottom = seq.count > 4 ? seq[4] : " "
            return left + bottom + top + right // ex. seq "1↓←↑→" -> "←↓↑→"
        default:
            return nil
        }
    }

    static let ignoredSequence = "-ignore-"

    var sequence: [String]? {
        switch self {
        case let .seq(s, _): return Array(s).map{String($0)}
        case .inputModeChange: return [KanaFlickKey.ignoredSequence,"_","かな","カナ","ｶﾅ"]
        case .space: return [KanaFlickKey.ignoredSequence, NSLocalizedString("SkipPartialCandidate", comment: "")]
        default: return nil
        }
    }

    var isControl: Bool {
        switch self {
        case .seq(_): return false
        default: return true
        }
    }

    var isRepeat: Bool {
        switch self {
        case .backspace: return true
        default: return false
        }
    }

    var hashValue: Int {
        switch self {
        case .seq(_): return 0
        case .shift: return 1
        case .return: return 2
        case .backspace: return 3
        case .keyboardChange: return 4
        case .inputModeChange: return 5
        case .number: return 6
        case .alphabet: return 7
        case .komojiDakuten: return 8
        case .upperLower: return 9
        case .space: return 10
        case .nothing: return 11
        }
    }
}

func ==(l: KanaFlickKey, r: KanaFlickKey) -> Bool {
    switch (l, r) {
    case let (.seq(ls, lShowSeqs), .seq(rs, rShowSeqs)): return ls == rs && lShowSeqs && rShowSeqs
    default: return l.hashValue == r.hashValue
    }
}
