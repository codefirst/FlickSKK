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
    private let remote : NSURL
    private let local : NSURL

    // MARK: - handler
    // FIXME: delegateにしたほうがiOSっぽいので直したほうがいい?
    // 辞書追加に成功した際の処理
    var success : (DictionaryInfo->Void)?

    // 辞書追加でエラーが発生した際の処理
    var error : ((String, ErrorType?)->Void)?

    // ダウンロードが進捗した際の処理
    var progress : ((String, Float) -> Void)?

    // MARK: -

    init(url : NSURL) {
        self.remote = url

        let local = DictionarySettings.additionalDictionaryURL()
        try! NSFileManager.defaultManager().createDirectoryAtURL(local, withIntermediateDirectories: true, attributes: nil)
        self.local = local
    }

    func call() {
        let downloadFile = Tempfile.temp()
        let utf8File = Tempfile.temp()

        // ダウンロード
        save(self.remote, path: downloadFile,
            onSuccess: {
                do {
                    // UTF8へのエンコード
                    try self.encodeToUTF8(downloadFile, dest: utf8File)

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
                error?(NSLocalizedString("DownloadError", comment:""), e)
            })
    }

    // URLを特定ファイルに保存する。
    private func save(url : NSURL, path: NSURL, onSuccess : Void -> Void, onError : ErrorType? -> Void) {
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
    private func encodeToUTF8(src : NSURL, dest: NSURL) throws {
        let content = try readFile(src)
        if let file = LocalFile(url: dest) {
            defer { file.close() }
            file.write(content as String)
        }
    }

    // ファイルをEUC-JPもしくはUTF-8として読み込む
    // (シミュレータではEUC-JPの読み込みは失敗する)
    private func readFile(url : NSURL) throws -> NSString {
        if let content = try? NSString(contentsOfURL: url, encoding: NSJapaneseEUCStringEncoding) {
            return content
        }
        return try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
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