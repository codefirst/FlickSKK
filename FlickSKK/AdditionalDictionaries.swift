// 追加辞書の情報一覧を管理する
//
// 設定画面で表示したりする、有効な辞書一覧や追加できる辞書一覧を取得する。
class AdditionalDictionaries {
    typealias Entry = (title: String, url: String, path: String?)

    private let defaultDictionaries : [Entry] = [
        (title: "人名辞書",
            url: "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei",
            path: nil),
        (title: "郵便番号辞書",
            url: "http://openlab.jp/skk/skk/dic/zipcode/SKK-JISYO.zipcode",
            path: nil),
        (title: "沖縄辞書",
            url: "http://openlab.jp/skk/skk/dic/SKK-JISYO.okinawa",
            path: nil),
        (title: "絵文字辞書",
            url: "https://raw.githubusercontent.com/uasi/skk-emoji-jisyo/master/SKK-JISYO.emoji.utf8",
            path: nil),
        (title: "その他(URL指定)", url: "", path: nil)
    ]

    // すでに追加した辞書のファイル名
    private lazy var dictionaryFiles = SKKDictionary.additionalDictionaries()

    // 有効になった(追加した)辞書一覧の取得
    func enabledDictionaries() -> [Entry] {
        return dictionaryFiles.map { path in
            self.dictionaryForPath(path).map {
                self.copy($0, path: path)
            } ?? (title: path, url: "", path: path)
        }
    }

    // 有効にできる辞書一覧を取得する
    func availableDictionaries() -> [Entry] {
        let names = dictionaryFiles.map { $0.lastPathComponent }
        return defaultDictionaries.filter { entry in
            !contains(names, entry.url.lastPathComponent)
        }
    }

    private func dictionaryForPath(path : String) -> Entry? {
        let name = path.lastPathComponent
        for entry in defaultDictionaries {
            if entry.url.lastPathComponent == name {
                return entry
            }
        }
        return nil
    }

    private func copy(entry : Entry, path : String) -> Entry {
        // XXX: 名前付きタプルのうち、一部だけを書き換える。そのうちシンタックスが搭載されると信じてる。
        return (title: entry.title, url: entry.url, path: path)
    }
}