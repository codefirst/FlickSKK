// FlickSKKで使う辞書のインタフェース
// メモリを節約するために
// ・辞書のロードの非同期実行
// ・ロード結果のキャッシュ
// などを行なう。
class SKKDictionary : NSObject {
    // すべての辞書(先頭から順に検索される)
    private var dictionaries : [ SKKDictionaryFile ] = []

    // ダイナミック変換用辞書
    private var dynamicDictionaries : [ SKKUserDictionaryFile ] = []

    // ユーザ辞書
    private var userDictionary : SKKUserDictionaryFile?

    // 学習辞書
    private var learnDictionary : SKKUserDictionaryFile?

    // 略語辞書
    private var partialDictionary : SKKUserDictionaryFile?

    // ロード完了を監視するために Key value observing を使う
    dynamic var isWaitingForLoad : Bool = false
    class func isWaitingForLoadKVOKey() -> String { return "isWaitingForLoad" }

    private let loader = AsyncLoader()
    private let cache = DictionaryCache()

    class func resetLearnDictionary() {
        for url in [DictionarySettings.defaultLearnDictionaryURL(), DictionarySettings.defaultPartialDictionaryURL()] {
            let _ = try? NSFileManager.defaultManager().removeItemAtURL(url)
        }
    }

    class func additionalDictionaries() -> [NSURL] {
        do {
            let manager = NSFileManager.defaultManager()
            let url = DictionarySettings.additionalDictionaryURL()
            return try manager.contentsOfDirectoryAtURL(url,
                includingPropertiesForKeys: nil,
                options: [])
        } catch {
            return []
        }
    }

    override init() {
        super.init()
        loader.load {
            let dictionary = self.cache.loadLocalDicitonary(DictionarySettings.defaultDicitonaryURL()) {
                SKKLocalDictionaryFile(url: $0)
            }
            self.userDictionary  = self.cache.loadUserDicitonary(DictionarySettings.defaultUserDictionaryURL()) {
                SKKUserDictionaryFile(url: $0)
            }
            self.learnDictionary = self.cache.loadUserDicitonary(DictionarySettings.defaultLearnDictionaryURL()) {
                SKKUserDictionaryFile(url: $0)
            }

            self.partialDictionary = self.cache.loadUserDicitonary(DictionarySettings.defaultPartialDictionaryURL()){
                SKKUserDictionaryFile(url: $0)
            }

            let xs : [SKKDictionaryFile] = SKKDictionary.additionalDictionaries().map { url in
                self.cache.loadUserDicitonary(url) {
                    SKKLocalDictionaryFile(url: $0)
                }
            }

            self.dictionaries = [ self.learnDictionary!, self.userDictionary!, dictionary ] + xs
            self.dynamicDictionaries = [ self.partialDictionary!, self.learnDictionary!, self.userDictionary! ]
        }
    }

    // 辞書を検索する
    func find(normal : String, okuri : String?) -> [ String ] {
        self.waitForLoading()

        let xs : [String] = self.dictionaries.flatMap {
            $0.find(normal, okuri: okuri)
        }.unique()

        return xs
    }

    // ダイナミック変換用の辞書検索
    func findDynamic(prefix : String) -> [(kana: String, kanji: String)] {
        self.waitForLoading()

        let xs : [(kana : String, kanji: String)] = self.dynamicDictionaries.flatMap {
            $0.findWith(prefix)
        }.uniqueBy { c in c.kanji }

        return xs
    }

    // 単語を登録する
    func register(normal : String, okuri: String?, kanji: String) {
        userDictionary?.register(normal, okuri: okuri, kanji: kanji)
        async {
            self.cache.update(DictionarySettings.defaultUserDictionaryURL()) {
                self.userDictionary?.serialize()
            }
        }
    }

    // 確定結果を学習する
    func learn(normal : String, okuri: String?, kanji: String) {
        learnDictionary?.register(normal, okuri: okuri, kanji: kanji)
        async {
            self.cache.update(DictionarySettings.defaultLearnDictionaryURL()) {
                self.learnDictionary?.serialize()
            }
        }
    }

    // InputModeChangeによる確定を学習する
    func partial(kana: String, okuri: String?, kanji: String) {
        partialDictionary?.register(kana, okuri: okuri, kanji: kanji)
        async {
            self.cache.update(DictionarySettings.defaultPartialDictionaryURL()) {
                self.partialDictionary?.serialize()
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
        let url = DictionarySettings.defaultUserDictionaryURL()
        return SKKUserDictionaryFile(url: url)
    }
}
