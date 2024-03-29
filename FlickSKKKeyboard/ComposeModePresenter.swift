// ComposeModeを表示する
class ComposeModePresenter {
    /// 入力先のアプリにマーク付きテキストで表示する未確定文字列
    func markedText(_ composeMode : ComposeMode) -> String? {
        switch composeMode {
        case .directInput:
            return nil
        case .kanaCompose(kana: let kana, candidates: _):
            return kana
        case .kanjiCompose(kana: _, okuri: _, candidates: let candidates, index: let index):
            return candidates[index].kanji
        case .wordRegister(kana: _, okuri: _, composeText: let text, composeMode: let m):
            let nested = markedText(m[0])
            return text + (nested ?? "")
        }
    }

    /// 変換中にキーボードの先頭に表示する文字列
    func composeText(_ composeMode : ComposeMode) -> String? {
        switch composeMode {
        case .directInput:
            return nil
        case .kanaCompose:
            return "▽"
        case .kanjiCompose:
            return "▼"
        case .wordRegister(kana: let kana, okuri: let okuri, composeText: let text, composeMode: let m):
            let prefix = kana + (okuri.map({ str in "*" + str }) ?? "")
            let nested = composeText(m[0])
            return "[登録:\(prefix)]\(text)\(nested ?? "")"
        }
    }

    // 候補の取得
    func candidates(_ composeMode : ComposeMode) -> (candidates: [Candidate], index: Int?)? {
        switch composeMode {
        case .directInput:
            return .none
        case .kanaCompose(kana: _, candidates: let candidates):
            return (candidates, .none)
        case .kanjiCompose(kana: _, okuri: _, candidates: let candidates, index: let index):
            return (candidates, index)
        case .wordRegister(kana : _, okuri : _, composeText : _, composeMode : let m):
            return candidates(m[0])
        }
    }

    // スペースか次候補か
    func inStatusShowsCandidatesBySpace(_ composeMode : ComposeMode) -> Bool {
        switch composeMode {
        case .directInput:
            return false
        case .kanaCompose:
            return true
        case .kanjiCompose(kana: _, okuri: _, candidates: _, index: _):
            return true
        case .wordRegister(kana : _, okuri : _, composeText : _, composeMode : let m):
            return inStatusShowsCandidatesBySpace(m[0]
            )
        }
    }

    /// wordRegisterの初期状態か(初期状態に入ったときにhapticするため)
    func isOnInitialStateOfWordRegister(_ composeMode : ComposeMode) -> Bool {
        switch composeMode {
        case .directInput, .kanaCompose, .kanjiCompose: return false
        case .wordRegister(kana: _, okuri: _, composeText: let composeText, composeMode: let composeMode):
            guard let mode = composeMode.first else { return false }
            switch mode {
            case .directInput: return composeText.isEmpty
            case .kanaCompose, .kanjiCompose, .wordRegister: return isOnInitialStateOfWordRegister(mode)
            }
        }
    }
}
