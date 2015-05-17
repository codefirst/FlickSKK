class DictionaryInfo {
    private let dictionary : LoadLocalDictionary

    init(dictionary : LoadLocalDictionary) {
        self.dictionary = dictionary
    }

    func okuriAri() -> Int {
        return self.dictionary.okuriAri().count
    }

    func okuriNasi() -> Int {
        return self.dictionary.okuriNasi().count
    }
}