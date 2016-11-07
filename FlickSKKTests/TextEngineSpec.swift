import Quick
import Nimble

class TextEngineSpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = Bundle(for: self.classForCoder)
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
                let _ = target.insertPartial("ハナヤマタ", kana: "はなやまた", status: TextEngine.Status.topLevel)
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
