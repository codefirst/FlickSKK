// FlickSKKで使う辞書のインタフェース
// メモリを節約するために
// ・辞書のロードの非同期実行
// ・ロード結果のキャッシュ
// などを行なう。
class SKKDictionary : NSObject {
    // すべての辞書(先頭から順に検索される)
    private var dictionaries : [ SKKDictionaryFile ] = []

    // ユーザ辞書
    private var userDictionary : SKKUserDictionaryFile?

    // 学習辞書
    private var learnDictionary : SKKUserDictionaryFile?

    // ロード完了を監視するために Key value observing を使う
    dynamic var isWaitingForLoad : Bool = false
    class func isWaitingForLoadKVOKey() -> String { return "isWaitingForLoad" }

    private let loader = AsyncLoader()
    private let cache = DictionaryCache()

    class func resetLearnDictionary() {
        let path = DictionarySettings.defaultLearnDictionaryPath()
        NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
    }

    override init() {
        super.init()
        loader.load {
            let dictionary =
                self.cache.loadLocalDicitonary(DictionarySettings.defaultDicitonaryPath()) {
                    return SKKLocalDictionaryFile(path: $0)
                }
            self.userDictionary  = self.cache.loadUserDicitonary(DictionarySettings.defaultUserDictionaryPath()) {
                    return SKKUserDictionaryFile(path: $0)
                }
            self.learnDictionary =
                self.cache.loadUserDicitonary(DictionarySettings.defaultLearnDictionaryPath()) {
                return SKKUserDictionaryFile(path: $0)
            }
            self.dictionaries = [ self.learnDictionary!, self.userDictionary!, dictionary ]
        }
    }

    // 辞書を検索する
    func find(normal : String, okuri : String?) -> [ String ] {
        self.waitForLoading()

        let xs : [String] = self.dictionaries.map({(dict : SKKDictionaryFile) -> [String] in
            dict.find(normal, okuri: okuri)
        }).reduce([],
                  combine: {(x : [String], y : [String]) -> [String] in
            x + y
        }).unique()

        return xs
    }

    // アグレッシブ変換用の辞書検索
    func findDynamic(prefix : String) -> [(kana: String, kanji: String)] {
        self.waitForLoading()
        let xs = self.learnDictionary?.findWith(prefix) ?? []
        let ys = self.userDictionary?.findWith(prefix) ?? []
        return xs + ys
    }

    // 単語を登録する
    func register(normal : String, okuri: String?, kanji: String) {
        userDictionary?.register(normal, okuri: okuri, kanji: kanji)
        loader.async {
            self.cache.update(DictionarySettings.defaultUserDictionaryPath()) {
                self.userDictionary?.serialize()
                ()
            }
        }
    }

    // 確定結果を学習する
    func learn(normal : String, okuri: String?, kanji: String) {
        learnDictionary?.register(normal, okuri: okuri, kanji: kanji)
        loader.async {
            self.cache.update(DictionarySettings.defaultLearnDictionaryPath()) {
                self.learnDictionary?.serialize()
                ()
            }
        }
    }

    // 辞書のロード完了を待つ
    func waitForLoading() {
        if loader.initialized { return }

        self.isWaitingForLoad = true
        self.loader.wait()
        self.isWaitingForLoad = false
    }

    // ユーザ辞書を取得する(設定アプリ用)
    class func defaultUserDictionary() -> SKKUserDictionaryFile {
        let path = DictionarySettings.defaultUserDictionaryPath()
        return SKKUserDictionaryFile(path: path)
    }
}
