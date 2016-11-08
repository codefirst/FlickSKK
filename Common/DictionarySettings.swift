import AppGroup

// 辞書のパスを管理する
class DictionarySettings {
    // テスト時は違うBundleからロードする
    // FIXME: もっといい感じに書きたい
    fileprivate struct ClassProperty {
        static var bundle : Bundle?
    }
    class var bundle: Bundle? {
        get {
            return ClassProperty.bundle
        }
        set {
            ClassProperty.bundle = newValue
        }
    }

    // ユーザ辞書(単語登録)
    class func defaultUserDictionaryURL() -> URL {
        return AppGroup.url(forResource: "Library/skk.jisyo") ?? home("Library/skk.jisyo")
    }

    // 変換結果の学習
    class func defaultLearnDictionaryURL() -> URL {
        return AppGroup.url(forResource: "Library/skk.learn.jisyo") ?? home("Library/skk.learn.jisyo")
    }

    // q確定の結果の学習
    class func defaultPartialDictionaryURL() -> URL {
        return AppGroup.url(forResource: "Library/skk.partial.jisyo") ?? home("Library/skk.partial.jisyo")
    }

    // 追加辞書
    class func additionalDictionaryURL() -> URL {
        return AppGroup.url(forResource: "Library/additional") ?? home("Library/additional")
    }

    // 組込みの辞書(L辞書とか)
    class func defaultDicitonaryURL() -> URL {
       // 辞書は必ず組込まれているはず
       return (DictionarySettings.bundle ?? Bundle.main).url(forResource: "skk", withExtension: "jisyo")!
    }

    class func home(_ path : String) -> URL {
        return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true).appendingPathComponent(path)
    }
}
