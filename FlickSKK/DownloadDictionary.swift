import Alamofire

// URLで指定された辞書をダウンロードし、FlickSKKで利用できるように整形する。
//
// おもに以下の処理を行なう。
//  1. ダウンロード
//  2. UTF-8への変換
//  3. 辞書の再ソート(※辞書はいわゆる「辞書順」で並んでいるため、文字コードを変換した後は、再ソートが必要。)
//
// もしかしたらダウンロード済みの辞書を統合したほうが高速化ができるかもしれないが、
// とりあえず現バージョンでは対応しない。
class DownloadDictionary {
    fileprivate let remote : URL
    fileprivate let local : URL

    // MARK: - handler
    // FIXME: delegateにしたほうがiOSっぽいので直したほうがいい?
    // 辞書追加に成功した際の処理
    var success : ((DictionaryInfo)->Void)?

    // 辞書追加でエラーが発生した際の処理
    var error : ((String, Error?)->Void)?

    // ダウンロードが進捗した際の処理
    var progress : ((String, Float) -> Void)?

    // MARK: -

    init(url : URL) {
        self.remote = url

        let local = DictionarySettings.additionalDictionaryURL()
        try! FileManager.default.createDirectory(at: local as URL, withIntermediateDirectories: true, attributes: nil)
        self.local = local.appendingPathComponent(url.lastPathComponent ?? "skk.jisyo")!
    }

    func call() {
        let downloadFile = Tempfile.temp()
        let utf8File = Tempfile.temp()

        // ダウンロード
        save(self.remote, path: downloadFile as URL,
            onSuccess: {
                do {
                    // UTF8へのエンコード
                    try self.encodeToUTF8(downloadFile as URL, dest: utf8File as URL)

                    // メインスレッドはプログラスバーの更新を行なうので辞書の検証等は別スレッドで行なう。
                    async {
                        let dictionary = LoadLocalDictionary(url: utf8File)

                        // 妥当性のチェック
                        if self.validate(dictionary) {
                            // 再ソート
                            SortDictionary(dictionary: dictionary).call(self.local)

                            // 結果のサマリを渡す
                            let info = DictionaryInfo(dictionary: dictionary)
                            self.success?(info)
                        } else {
                            self.error?(NSLocalizedString("InvalidDictionary", comment:""), nil)
                        }
                    }
                } catch let e {
                    self.error?(NSLocalizedString("EncodingError", comment:""), e)
                }
            },
            onError: { e in
                self.error?(NSLocalizedString("DownloadError", comment:""), e)
            })
    }

    // URLを特定ファイルに保存する。
    fileprivate func save(_ url : URL, path: URL, onSuccess : @escaping (Void) -> Void, onError : @escaping (Error?) -> Void) {
        Alamofire.download(.GET, url) { (temporaryURL, response) in
            return path ?? temporaryURL
        }.progress { (_, totalBytesRead, totalBytesExpectedToRead) in
            let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
            self.progress?(NSLocalizedString("Downloading", comment:""), progress / 2)
        }.response { (request, response, _, error) in
            if let e = error {
                onError(e)
            } else {
                if response?.statusCode == 200 {
                    onSuccess()
                } else {
                    onError(nil)
                }
            }
        }
    }

    // UTF8でエンコードして、保存する
    fileprivate func encodeToUTF8(_ src : URL, dest: URL) throws {
        let content = try readFile(src)
        if let file = LocalFile(url: dest) {
            defer { file.close() }
            file.write(content as String)
        }
    }

    // ファイルをEUC-JPもしくはUTF-8として読み込む
    // (シミュレータではEUC-JPの読み込みは失敗する)
    fileprivate func readFile(_ url : URL) throws -> NSString {
        if let content = try? NSString(contentsOf: url, encoding: String.Encoding.japaneseEUC.rawValue) {
            return content
        }
        return try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
    }

    // 辞書の検証をする
    // 検証の進捗状況は逐次表示する
    fileprivate func validate(_ dictionary : LoadLocalDictionary) -> Bool {
        let validate = ValidateDictionary(dictionary: dictionary)
        validate.progress = { (current, total) in
            let progress = Float(current) / Float(total)
            self.progress?(NSLocalizedString("Validating", comment:""), progress / 2 + 0.5)
        }
        return validate.call()
    }
}
