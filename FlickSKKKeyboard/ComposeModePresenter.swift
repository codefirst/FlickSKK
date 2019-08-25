// ComposeModeを表示する
class ComposeModePresenter {
    /// (iOS 13未満用(markedTextなしで全ての情報を返す)) 表示用文字列(▽あああ、みたいなやつ)
    func toString(_ composeMode : ComposeMode) -> String {
        switch composeMode {
        case .directInput:
            return ""
        case .kanaCompose(kana: let kana, candidates: _):
            return "▽\(kana)"
        case .kanjiCompose(kana: let kana, okuri: let okuri, candidates: _, index: _):
            let text = kana + (okuri.map({ str in "*" + str }) ?? "")
            return "▼\(text)"
        case .wordRegister(kana : let kana, okuri : let okuri, composeText : let text, composeMode : let m):
            let prefix = kana + (okuri.map({ str in "*" + str }) ?? "")
            let nested = toString(m[0])
            return "[登録:\(prefix)]\(text)\(nested)"
        }
    }

    /// 入力先のアプリにマーク付きテキストで表示する未確定文字列
    func markedText(_ composeMode : ComposeMode) -> String? {
        switch composeMode {
        case .directInput:
            return nil
        case .kanaCompose(kana: let kana, candidates: _):
            return kana
        case .kanjiCompose(kana: _, okuri: _, candidates: let candidates, index: let index):
            return candidates[index].kanji
        case .wordRegister(kana: _, okuri: let okuri, composeText: let text, composeMode: let m):
            let nested = markedText(m[0])
            return text + (okuri ?? "") + (nested ?? "")
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
        case .kanaCompose(_):
            return true
        case .kanjiCompose(kana: _, okuri: _, candidates: _, index: _):
            return true
        case .wordRegister(kana : _, okuri : _, composeText : _, composeMode : let m):
            return inStatusShowsCandidatesBySpace(m[0]
            )
        }
    }
}
