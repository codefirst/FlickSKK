import Quick
import Nimble

class SKKDictionarySpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = NSBundle(forClass: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
        }()

    override func spec() {
        describe("#findDynamic") {
            it("重複して取得しない") {
                self.dictionary.register("ほんき", okuri: nil, kanji: "本気")
                self.dictionary.learn("ほんき", okuri: nil, kanji: "本気")
                let xs = self.dictionary.findDynamic("ほん")
                expect(xs.count).to(equal(1))
                expect(xs[0].kanji).to(equal("本気"))
                expect(xs[0].kana).to(equal("ほんき"))
            }
        }

        describe("#find") {
            it("重複して取得しない") {
                self.dictionary.register("ほんき", okuri: nil, kanji: "本気")
                let xs = self.dictionary.find("ほんき", okuri: nil).filter { w in
                    w == "本気"
                }
                expect(xs.count).to(equal(1))
            }
        }
    }
}