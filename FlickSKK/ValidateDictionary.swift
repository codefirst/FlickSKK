// 辞書の妥当性をチェックする。
//
// 厳密なチェックはできないので、FlickSKK内で扱えるかどうかを簡易的にチェックする
class ValidateDictionary {
    private let dictionary : LoadLocalDictionary
    private let total : Int
    private var current : Int = 0
    var progress : ((Int, Int) -> Void)?

    init(dictionary : LoadLocalDictionary) {
        self.dictionary = dictionary
        self.total = self.dictionary.count()
    }

    func call() -> Bool {
        return validate(self.dictionary.okuriAri()) && validate(self.dictionary.okuriNasi())
    }

    private func validate(xs : NSArray) -> Bool {
        for x in xs {
            let entry = EntryParser(entry: x as! String)
            if entry.title() == nil || entry.words() == [] {
                return false
            }
            updateProgress()
        }
        return true
    }

    private func updateProgress() {
        current += 1
        self.progress?(current, total)
    }
}