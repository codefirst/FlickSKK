import Quick
import Nimble

class TextEngineSpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = Bundle(forClass: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
    }()

    override func spec() {
        var target : TextEngine!
        var delegate : MockDelegate!

        beforeEach {
            delegate = MockDelegate()
            let dictionaryEngine = DictionaryEngine(dictionary: self.dictionary)
            target = TextEngine(delegate: delegate, dictionary: dictionaryEngine)
        }

        describe("#insertPartial") {
            beforeEach {
                target.insertPartial("ハナヤマタ", kana: "はなやまた", status: TextEngine.Status.TopLevel)
            }

            it("挿入される") {
                expect(delegate.insertedText).to(equal("ハナヤマタ"))
            }

            it("補完できる") {
                let xs = self.dictionary.findDynamic("はなや").filter { w in w.kanji == "ハナヤマタ" }
                expect(xs.count).to(equal(1))
            }
        }
    }
}
