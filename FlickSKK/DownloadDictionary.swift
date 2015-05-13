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

    var success : (Void->Void)?
    var error : ((String,NSError)->Void)?
    var progress : ((Int64, Int64) -> Void)?

    init(url : String) {
        self.url = url

        let dir = DictionarySettings.additionalDictionaryPath()
        NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil, error: nil)
        self.path = dir.stringByAppendingPathComponent(url.lastPathComponent)
    }

    func call() {
        let downloadFile = Tempfile.temp()
        let utf8File = Tempfile.temp()

        // ダウンロード
        save(self.url, path: downloadFile,
            onSuccess: {
                // UTF8へのエンコード
                self.encodeToUTF8(downloadFile, dest: utf8File)
                // 再ソート
                SortDictionary(path: utf8File).call(self.path)
                self.success?()
            },
            onError: { e in
                error?(NSLocalizedString("DownloadError", comment:""), e)
            })
    }

    // URLを特定ファイルに保存する。
    private func save(url : String, path: String, onSuccess : Void -> Void, onError : NSError -> Void) {
        Alamofire.download(.GET, url) { (temporaryURL, response) in
            return NSURL.fileURLWithPath(path, isDirectory: false) ?? temporaryURL
        }.progress { (_, totalBytesRead, totalBytesExpectedToRead) in
            self.progress?(totalBytesRead, totalBytesExpectedToRead)
        }.response { (request, response, _, error) in
            if let e = error {
                onError(e)
            } else {
                onSuccess()
            }
        }
    }

    // UTF8でエンコードして、保存する
    private func encodeToUTF8(src : String, dest: String) {
        var error : NSError?
        if let content = readFile(src, error: &error) {
            if let file = LocalFile(path: dest) {
                file.write(content as String)
                file.close()
            }
        } else if let e = error {
            self.error?(NSLocalizedString("EncodingError", comment:""),e)
        }
    }

    // ファイルをEUC-JPもしくはUTF-8として読み込む
    // (シミュレータではEUC-JPの読み込みは失敗する)
    private func readFile(path : String, error: NSErrorPointer) -> NSString? {
        return NSString(contentsOfFile: path, encoding: NSJapaneseEUCStringEncoding, error: error) ??
            NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)

    }
}