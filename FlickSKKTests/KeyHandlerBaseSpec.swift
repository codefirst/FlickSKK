import Quick
import Nimble

class KeyHandlerBaseSpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = Bundle(for: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
    }()

    // キーハンドラの取得
    func create(_ dictionary : SKKDictionary) -> (KeyHandler, MockDelegate) {
        // 学習辞書をリセットする
        SKKDictionary.resetLearnDictionary()

        // キーハンドラの生成
        let delegate = MockDelegate()
        let handler = KeyHandler(delegate: delegate, dictionary: dictionary)

        return (handler, delegate)
    }

    func kana(_ composeMode : ComposeMode)  -> String? {
        switch composeMode {
        case .kanaCompose(kana : let kana, candidates: _):
            return kana
        default:
            return nil
        }
    }

    func kanji(_ composeMode : ComposeMode) -> (String, String)? {
        switch composeMode {
        case .kanjiCompose(kana: let kana, okuri : let okuri, candidates: _, index: _):
            return (kana, okuri ?? "")
        default:
            return nil
        }
    }

    func exacts(_ candidates: [String]) -> [Candidate] {
        return candidates.map { c in .exact(kanji : c) }
    }

    func candidates(_ composeMode : ComposeMode) -> [Candidate]? {
        switch composeMode {
        case .kanjiCompose(kana: _, okuri: _, candidates: let candidates, index: _):
            return candidates
        case .kanaCompose(kana: _, candidates: let candidates):
            return candidates
        default:
            return nil
        }
    }

    func index(_ composeMode: ComposeMode) -> Int? {
        switch composeMode {
        case .kanjiCompose(kana: _, okuri: _, candidates: _, index: let index):
            return index
        default:
            return nil
        }
    }
}
