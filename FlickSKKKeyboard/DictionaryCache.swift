private var kDicitonary : SKKLocalDictionaryFile?
private var kCache : [String:(NSDate, SKKUserDictionaryFile)] = [:]

// 辞書のロードには時間がかかるので、一度ロードした結果をキャッシュする
// グローバル変数にいれておけば、次回起動時にも残っている(ことがある)
class DictionaryCache {
    // L辞書等のインストール済みの辞書をロードする
    // FIXME: 現時点では二個以上の辞書ファイルは存在しないと仮定している
    func loadLocalDicitonary(path: String, closure: String -> SKKLocalDictionaryFile) -> SKKLocalDictionaryFile {
        if kDicitonary == nil {
            kDicitonary = closure(path)
        }
        return kDicitonary!
    }

    // ユーザごとに作られる辞書をロードする(例: 単語登録結果、学習結果)
    func loadUserDicitonary(path: String, closure: String -> SKKUserDictionaryFile) -> SKKUserDictionaryFile {
        if let mtime = getModifiedTime(path) {
            if let (Exact, file) = kCache[path] {
                if Exact == mtime {
                    // キャッシュが有効
                    NSLog("%@ is cached", path)
                    return file
                } else {
                    // キャシュが無効になっている
                    NSLog("%@ cache is expired", path)
                    let newFile = closure(path)
                    kCache[path] = (mtime, newFile)
                    return newFile
                }
            } else {
                // キャッシュが存在しない
                NSLog("%@ is cached", path)
                let file = closure(path)
                kCache[path] = (mtime, file)
                return file
            }
        } else {
            // ロード対象のファイルが存在しない
            return closure(path)
        }
    }

    // キャッシュの最終更新日時を更新する
    func update(path: String, closure : () -> ()) {
        closure()
        if let (_, file) = kCache[path] {
            if let mtime = getModifiedTime(path) {
                kCache[path] = (mtime, file)
            }
        }
    }

    private func getModifiedTime(path: String) -> NSDate? {
        let fm = NSFileManager.defaultManager()
        if let attrs = fm.attributesOfItemAtPath(path, error: nil) {
            return attrs[NSFileModificationDate] as? NSDate
        } else {
            return nil
        }
    }
}
