// 追加辞書の情報一覧を管理する
//
// 設定画面で表示したりする、有効な辞書一覧や追加できる辞書一覧を取得する。
class AdditionalDictionaries {
    typealias Entry = (title: String, url: URL?, local: URL?)

    fileprivate let defaultDictionaries : [Entry] = [
        (title: "人名辞書",
            url: URL(string: "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei"),
            local: nil),
        (title: "郵便番号辞書",
            url: URL(string: "http://openlab.jp/skk/skk/dic/zipcode/SKK-JISYO.zipcode"),
            local: nil),
        (title: "沖縄辞書",
            url: URL(string: "http://openlab.jp/skk/skk/dic/SKK-JISYO.okinawa"),
            local: nil),
        (title: "絵文字辞書",
            url: URL(string: "https://raw.githubusercontent.com/uasi/skk-emoji-jisyo/master/SKK-JISYO.emoji.utf8"),
            local: nil),
        (title: "その他(URL指定)", url: nil, local: nil)
    ]

    // すでに追加した辞書のファイル名
    fileprivate lazy var dictionaryFiles = SKKDictionary.additionalDictionaries()

    // 有効になった(追加した)辞書一覧の取得
    func enabledDictionaries() -> [Entry] {
        return dictionaryFiles.map { url in
            self.dictionaryForURL(url as URL).map {
                self.copy($0, local: url as URL)
                } ?? (title: url.lastPathComponent, url: nil, local: url as URL)
        }
    }

    // 有効にできる辞書一覧を取得する
    func availableDictionaries() -> [Entry] {
        let names : [String] = dictionaryFiles.compactMap { $0.lastPathComponent }
        return defaultDictionaries.filter { entry in
            !names.contains(entry.url?.lastPathComponent ?? "")
        }
    }

    fileprivate func dictionaryForURL(_ url : URL) -> Entry? {
        let name = url.lastPathComponent
        for entry in defaultDictionaries {
            if entry.url?.lastPathComponent == name {
                return entry
            }
        }
        return nil
    }

    fileprivate func copy(_ entry : Entry, local : URL) -> Entry {
        // XXX: 名前付きタプルのうち、一部だけを書き換える。そのうちシンタックスが搭載されると信じてる。
        return (title: entry.title, url: entry.url, local: local)
    }
}
