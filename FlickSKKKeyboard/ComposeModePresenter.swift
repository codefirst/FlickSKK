// ComposeModeを表示する
class ComposeModePresenter {
    // 表示用文字列(▽あああ、みたいなやつ)
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
            let nested = toString(m[0]) ?? ""
            return "[登録:\(prefix)]\(text)\(nested)"
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
