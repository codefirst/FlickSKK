import Quick
import Nimble

class KeyHandlerBaseSpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = NSBundle(forClass: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
    }()

    // キーハンドラの取得
    func create(dictionary : SKKDictionary) -> (KeyHandler, MockDelegate) {
        // 学習辞書をリセットする
        SKKDictionary.resetLearnDictionary()

        // キーハンドラの生成
        let delegate = MockDelegate()
        let handler = KeyHandler(delegate: delegate, dictionary: dictionary)

        return (handler, delegate)
    }

    func kana(composeMode : ComposeMode)  -> String? {
        switch composeMode {
        case .KanaCompose(kana : let kana, candidates: _):
            return kana
        default:
            return nil
        }
    }

    func kanji(composeMode : ComposeMode) -> (String, String)? {
        switch composeMode {
        case .KanjiCompose(kana: let kana, okuri : let okuri, candidates: _, index: _):
            return (kana, okuri ?? "")
        default:
            return nil
        }
    }

    func exacts(candidates: [String]) -> [Candidate] {
        return candidates.map { c in .Exact(kanji : c) }
    }

    func candidates(composeMode : ComposeMode) -> [Candidate]? {
        switch composeMode {
        case .KanjiCompose(kana: _, okuri: _, candidates: let candidates, index: _):
            return candidates
        case .KanaCompose(kana: _, candidates: let candidates):
            return candidates
        default:
            return nil
        }
    }

    func index(composeMode: ComposeMode) -> Int? {
        switch composeMode {
        case .KanjiCompose(kana: _, okuri: _, candidates: _, index: let index):
            return index
        default:
            return nil
        }
    }
}