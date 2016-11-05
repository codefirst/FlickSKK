// L辞書などの固定辞書。
//
// ユーザ辞書と異なり
//  - 単語登録などのメソッドを持たない
//  - 各単語がソートされている。
// といった特徴を持つ。
class SKKLocalDictionaryFile : SKKDictionaryFile {
    fileprivate let okuriAri : BinarySearch
    fileprivate let okuriNasi : BinarySearch
    fileprivate let url : URL
    fileprivate let filters : [SKKFilter] = [
        IdFilter(), NumberFilter()
    ]
    init(url : URL){
        self.url = url
        let now = Date()
        let dictionary = LoadLocalDictionary(url: url)

        self.okuriAri = BinarySearch(entries: dictionary.okuriAri(), reverse: true)
        self.okuriNasi = BinarySearch(entries: dictionary.okuriNasi(), reverse: false)
        NSLog("loaded (%f)\n", Date().timeIntervalSince(now))
    }

    func find(_ normal : String, okuri : String?) -> [ String ] {
        switch okuri {
        case .none:
            return search(normal + " ", at: self.okuriNasi)
        case .some(let okuri):
            return search(normal + okuri + " ", at: self.okuriAri)
        }
    }

    fileprivate func search(_ target : String, at: BinarySearch) -> [String] {
        return filters.flatMap { filter in
            filter.call(target, binarySearch: at) {
                EntryParser(entry: $0).words()
            }
        }
    }
}
