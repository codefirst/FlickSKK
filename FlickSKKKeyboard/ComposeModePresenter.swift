// ComposeModeを表示する
class ComposeModePresenter {
    // 表示用文字列(▽あああ、みたいなやつ)
    func toString(composeMode : ComposeMode) -> String {
        switch composeMode {
        case .DirectInput:
            return ""
        case .KanaCompose(kana: let kana, candidates: _):
            return "▽\(kana)"
        case .KanjiCompose(kana: _, okuri: _, candidates: let candidates, index: let index):
            return "▼\(candidates[index])"
        case .WordRegister(kana : let kana, okuri : let okuri, composeText : let text, composeMode : let m):
            let prefix = kana + (okuri.map({ str in "*" + str }) ?? "")
            let nested = toString(m[0]) ?? ""
            return "[登録:\(prefix)]\(text)\(nested)"
        }
    }

    // 候補の取得
    func candidates(composeMode : ComposeMode) -> (candidates: [String], index: Int?)? {
        switch composeMode {
        case .DirectInput:
            return .None
        case .KanaCompose(kana: _, candidates: let candidates):
            return (candidates, .None)
        case .KanjiCompose(kana: _, okuri: _, candidates: let candidates, index: let index):
            return (candidates, index)
        case .WordRegister(kana : _, okuri : _, composeText : _, composeMode : let m):
            return candidates(m[0])
        }
    }

    // スペースか次候補か
    func inStatusShowsCandidatesBySpace(composeMode : ComposeMode) -> Bool {
        switch composeMode {
        case .DirectInput:
            return false
        case .KanaCompose(kana: let kana):
            return false
        case .KanjiCompose(kana: _, okuri: _, candidates: let candidates, index: let index):
            return true
        case .WordRegister(kana : _, okuri : _, composeText : _, composeMode : let m):
            return inStatusShowsCandidatesBySpace(m[0]
            )
        }
    }
}
