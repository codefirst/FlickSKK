private var kGlobalDictionary: SKKDictionary?
private var kLoadedTime : NSDate? = nil

// 辞書のロードには時間がかかるので、一度ロードした結果をキャッシュする
// グローバル変数にいれておけば、次回起動時にも残っている(ことがある)
class DictionaryCache {
    class func load() -> SKKDictionary? {
        let userDict = SKKUserDictionaryFile.defaultUserDictionaryPath()
        let learnDict = SKKUserDictionaryFile.defaultLearnDictionaryPath()
        let mtime = getModifiedTime(userDict)

        if kGlobalDictionary == nil || kLoadedTime != mtime {
            let dict = NSBundle.mainBundle().pathForResource("skk", ofType: "jisyo")
            kGlobalDictionary = SKKDictionary(userDict: userDict, learnDict: learnDict, dicts: [dict!])
            kLoadedTime = mtime
        }

        return kGlobalDictionary
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