// L辞書などの固定辞書。
//
// ユーザ辞書と異なり
//  - 単語登録などのメソッドを持たない
//  - 各単語がソートされている。
// といった特徴を持つ。
class SKKLocalDictionaryFile : SKKDictionaryFile {
    private let okuriAri : BinarySearch
    private let okuriNasi : BinarySearch
    private let path : String
    init(path : String){
        self.path = path
        let now = NSDate()
        let dictionary = LoadLocalDictionary(path: path)

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

    private func search(target : NSString, at: BinarySearch) -> [String] {
        let preprocessor = SKKNumberPreprocessor(value: target as String)

        let line = at.call(preprocessor.preProcess()) ?? ""
        let entries = EntryParser(entry: line).words()

        return entries.map({ entry in
            return preprocessor.postProcess(entry) })
    }
}
