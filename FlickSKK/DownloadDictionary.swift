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
    private let url : String
    private let path : String

    // MARK: - handler
    // FIXME: delegateにしたほうがiOSっぽいので直したほうがいい?
    // 辞書追加に成功した際の処理
    var success : (DictionaryInfo->Void)?

    // 辞書追加でエラーが発生した際の処理
    var error : ((String, ErrorType?)->Void)?

    // ダウンロードが進捗した際の処理
    var progress : ((String, Float) -> Void)?

    // MARK: -

    init(url : String) {
        self.url = url

        let dir = DictionarySettings.additionalDictionaryPath()
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        self.path = dir.stringByAppendingPathComponent(url.lastPathComponent)
    }

    func call() {
        let downloadFile = Tempfile.temp()
        let utf8File = Tempfile.temp()

        // ダウンロード
        save(self.url, path: downloadFile,
            onSuccess: {
                do {
                    // UTF8へのエンコード
                    try self.encodeToUTF8(downloadFile, dest: utf8File)

                    // メインスレッドはプログラスバーの更新を行なうので辞書の検証等は別スレッドで行なう。
                    async {
                        let dictionary = LoadLocalDictionary(path: utf8File)

                        // 妥当性のチェック
                        if self.validate(dictionary) {
                            // 再ソート
                            SortDictionary(dictionary: dictionary).call(self.path)

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
                error?(NSLocalizedString("DownloadError", comment:""), e)
            })
    }

    // URLを特定ファイルに保存する。
    private func save(url : String, path: String, onSuccess : Void -> Void, onError : ErrorType? -> Void) {
        Alamofire.download(.GET, url) { (temporaryURL, response) in
            return NSURL.fileURLWithPath(path, isDirectory: false) ?? temporaryURL
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
    private func encodeToUTF8(src : String, dest: String) throws {
        let content = try readFile(src)
        if let file = LocalFile(path: dest) {
            defer { file.close() }
            file.write(content as String)
        }
    }

    // ファイルをEUC-JPもしくはUTF-8として読み込む
    // (シミュレータではEUC-JPの読み込みは失敗する)
    private func readFile(path : String) throws -> NSString {
        if let content = try? NSString(contentsOfFile: path, encoding: NSJapaneseEUCStringEncoding) {
            return content
        }
        return try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
    }

    // 辞書の検証をする
    // 検証の進捗状況は逐次表示する
    private func validate(dictionary : LoadLocalDictionary) -> Bool {
        let validate = ValidateDictionary(dictionary: dictionary)
        validate.progress = { (current, total) in
            let progress = Float(current) / Float(total)
            self.progress?(NSLocalizedString("Validating", comment:""), progress / 2 + 0.5)
        }
        return validate.call()
    }
}