// L辞書などの固定辞書。
//
// ユーザ辞書と異なり
//  - 単語登録などのメソッドを持たない
//  - 各単語がソートされている。
// といった特徴を持つ。
class SKKLocalDictionaryFile : SKKDictionaryFile {
    private let okuriAri : BinarySearch
    private let okuriNasi : BinarySearch
    private let url : NSURL
    private let filters : [SKKFilter] = [
        IdFilter(), NumberFilter()
    ]
    init(url : NSURL){
        self.url = url
        let now = NSDate()
        let dictionary = LoadLocalDictionary(url: url)

        self.okuriAri = BinarySearch(entries: dictionary.okuriAri(), reverse: true)
        self.okuriNasi = BinarySearch(entries: dictionary.okuriNasi(), reverse: false)
        NSLog("loaded (%f)\n", NSDate().timeIntervalSinceDate(now))
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        switch okuri {
        case .None:
            return search(normal + " ", at: self.okuriNasi)
        case .Some(let okuri):
            return search(normal + okuri + " ", at: self.okuriAri)
        }
    }

    private func search(target : String, at: BinarySearch) -> [String] {
        return filters.flatMap { filter in
            filter.call(target, binarySearch: at) {
                EntryParser(entry: $0).words()
            }
        }
    }
}
