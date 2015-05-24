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
    class func defaultUserDictionaryPath() -> String {
        return AppGroup.pathForResource("Library/skk.jisyo") ?? NSHomeDirectory().stringByAppendingPathComponent("Library/skk.jisyo")
    }

    // 変換結果の学習
    class func defaultLearnDictionaryPath() -> String {
        return AppGroup.pathForResource("Library/skk.learn.jisyo") ??
            NSHomeDirectory().stringByAppendingPathComponent("Library/skk.learn.jisyo")
    }

    // q確定の結果の学習
    class func defaultPartialDictionaryPath() -> String {
        return AppGroup.pathForResource("Library/skk.partial.jisyo") ??
            NSHomeDirectory().stringByAppendingPathComponent("Library/skk.partial.jisyo")
    }

    // 追加辞書
    class func additionalDictionaryPath() -> String {
        return AppGroup.pathForResource("Library/additional") ??
            NSHomeDirectory().stringByAppendingPathComponent("Library/additional")
    }

    // 組込みの辞書(L辞書とか)
    class func defaultDicitonaryPath() -> String {
       // 辞書は必ず組込まれているはず
       return (DictionarySettings.bundle ?? NSBundle.mainBundle()).pathForResource("skk", ofType: "jisyo")!
    }
}
