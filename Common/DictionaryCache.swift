private var kDicitonary : SKKLocalDictionaryFile?
private var kCache : [URL:(Date, Any)] = [:]

// 辞書のロードには時間がかかるので、一度ロードした結果をキャッシュする
// グローバル変数にいれておけば、次回起動時にも残っている(ことがある)
class DictionaryCache {
    // L辞書等のインストール済みの辞書をロードする
    // FIXME: 現時点では二個以上の辞書ファイルは存在しないと仮定している
    func loadLocalDicitonary(_ url: URL, closure: (URL) -> SKKLocalDictionaryFile) -> SKKLocalDictionaryFile {
        if kDicitonary == nil {
            kDicitonary = closure(url)
        }
        return kDicitonary!
    }

    // ユーザごとに作られる辞書をロードする(例: 単語登録結果、学習結果)
    func loadUserDicitonary<T>(_ url: URL, closure: (URL) -> T) -> T {
        if let mtime = getModifiedTime(url) {
            if let (Exact, file) = kCache[url] {
                if Exact == mtime {
                    // キャッシュが有効
                    return file as! T
                } else {
                    // キャシュが無効になっている
                    let newFile = closure(url)
                    kCache[url] = (mtime, newFile)
                    return newFile
                }
            } else {
                // キャッシュが存在しない
                let file = closure(url)
                kCache[url] = (mtime, file)
                return file
            }
        } else {
            // ロード対象のファイルが存在しない
            return closure(url)
        }
    }

    // キャッシュの最終更新日時を更新する
    func update(_ url: URL, closure : () -> ()) {
        closure()
        if let (_, file) = kCache[url] {
            if let mtime = getModifiedTime(url) {
                kCache[url] = (mtime, file)
            }
        }
    }

    fileprivate func getModifiedTime(_ url: URL) -> Date? {
        let fm = FileManager.default
        let path = url.path
        guard let attrs = try? fm.attributesOfItem(atPath: path) else { return nil }
        return attrs[FileAttributeKey.modificationDate] as? Date
    }
}
