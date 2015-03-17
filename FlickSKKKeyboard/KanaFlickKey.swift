enum KanaFlickKey: Hashable {
    case Seq(String, showSeqs: Bool)
    case Shift
    case Return
    case Backspace
    case KeyboardChange
    case InputModeChange([SKKInputMode?])
    case Number
    case Alphabet
    case KomojiDakuten
    case UpperLower
    case Space
    case Nothing

    // メインの「あ」「A」「1」など
    var buttonLabel: String {
        switch self {
        case let .Seq(s, _): return String(s[s.startIndex])
        case .Shift: return "⇧"
        case .Return: return "⏎"
        case .Backspace: return "⌫"
        case .KeyboardChange: return ""
        case .InputModeChange: return "かな"
        case .Number: return "123"
        case .Alphabet: return "ABC"
        case .KomojiDakuten: return "小゛゜"
        case .UpperLower: return "a/A"
        case .Space: return "space"
        case .Nothing: return ""
        }
    }

    // 残りの「←↓↑→」など
    var additionalButtonLabel: String? {
        switch self {
        case let .Seq(s, true):
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

    var sequence: [String]? {
        switch self {
        case let .Seq(s, _): return Array(s).map{String($0)}
        case .InputModeChange: return ["-ignore-","_","かな","カナ","ｶﾅ"]
        default: return nil
        }
    }

    var isControl: Bool {
        switch self {
        case .Seq(_): return false
        default: return true
        }
    }

    var isRepeat: Bool {
        switch self {
        case .Backspace: return true
        default: return false
        }
    }

    var hashValue: Int {
        switch self {
        case .Seq(_): return 0
        case .Shift: return 1
        case .Return: return 2
        case .Backspace: return 3
        case KeyboardChange: return 4
        case .InputModeChange: return 5
        case .Number: return 6
        case .Alphabet: return 7
        case .KomojiDakuten: return 8
        case .UpperLower: return 9
        case .Space: return 10
        case .Nothing: return 11
        }
    }
}

func ==(l: KanaFlickKey, r: KanaFlickKey) -> Bool {
    switch (l, r) {
    case let (.Seq(ls, lShowSeqs), .Seq(rs, rShowSeqs)): return ls == rs && lShowSeqs && rShowSeqs
    default: return l.hashValue == r.hashValue
    }
}