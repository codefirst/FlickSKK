private var kGlobalDictionary: SKKDictionary?
private var kLoadedTime : [String:NSDate] = [:]

// 辞書のロードには時間がかかるので、一度ロードした結果をキャッシュする
// グローバル変数にいれておけば、次回起動時にも残っている(ことがある)
class DictionaryCache {
    class func load() -> SKKDictionary? {
        let userDict = SKKUserDictionaryFile.defaultUserDictionaryPath()
        let learnDict = SKKUserDictionaryFile.defaultLearnDictionaryPath()

        // 辞書がロードされていない or ユーザ辞書・学習辞書が更新されている場合は再ロードする
        if kGlobalDictionary == nil || isUpdated(userDict) || isUpdated(learnDict) {
            let dict = NSBundle.mainBundle().pathForResource("skk", ofType: "jisyo")
            kGlobalDictionary = SKKDictionary(userDict: userDict, learnDict: learnDict, dicts: [dict!])
        }

        return kGlobalDictionary
    }

    private class func isUpdated(path: String) -> Bool {
        return kLoadedTime[path] != getModifiedTime(path)
    }

    private class func cache(path: String) {
        kLoadedTime[path] = getModifiedTime(path)
    }

    private class func getModifiedTime(path: String) -> NSDate? {
        let fm = NSFileManager.defaultManager()
        if let attrs = fm.attributesOfItemAtPath(path, error: nil) {
            return attrs[NSFileModificationDate] as? NSDate
        } else {
            return nil
        }
    }
}