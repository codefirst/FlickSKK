import AppGroup

// 辞書のパスを管理する
class DictionarySettings {
    // テスト時は違うBundleからロードする
    // FIXME: もっといい感じに書きたい
    private struct ClassProperty {
        static var bundle : NSBundle?
    }
    class var bundle: NSBundle? {
        get {
            return ClassProperty.bundle
        }
        set {
            ClassProperty.bundle = newValue
        }
    }

    // ユーザ辞書(単語登録)
    class func defaultUserDictionaryURL() -> NSURL {
        return AppGroup.urlForResource("Library/skk.jisyo") ?? home("Library/skk.jisyo")
    }

    // 変換結果の学習
    class func defaultLearnDictionaryURL() -> NSURL {
        return AppGroup.urlForResource("Library/skk.learn.jisyo") ??
            home("Library/skk.learn.jisyo")
    }

    // q確定の結果の学習
    class func defaultPartialDictionaryURL() -> NSURL {
        return AppGroup.urlForResource("Library/skk.partial.jisyo") ??
            home("Library/skk.partial.jisyo")
    }

    // 追加辞書
    class func additionalDictionaryURL() -> NSURL {
        return AppGroup.urlForResource("Library/additional") ??
            home("Library/additional")
    }

    // 組込みの辞書(L辞書とか)
    class func defaultDicitonaryURL() -> NSURL {
       // 辞書は必ず組込まれているはず
       return (DictionarySettings.bundle ?? NSBundle.mainBundle()).URLForResource("skk", withExtension: "jisyo")!
    }

    class func home(path : String) -> NSURL {
        return NSURL(fileURLWithPath: NSHomeDirectory(), isDirectory: true).URLByAppendingPathComponent(path)
    }
}
