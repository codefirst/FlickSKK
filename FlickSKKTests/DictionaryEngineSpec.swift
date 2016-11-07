import Quick
import Nimble

class DictionaryEngineSpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = Bundle(for: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
        }()

    override func spec() {
        var dictionaryEngine : DictionaryEngine!

        beforeEach {
            dictionaryEngine = DictionaryEngine(dictionary: self.dictionary)
        }

        describe("#find") {
            it("送り仮名を補う") {
                expect(dictionaryEngine.find("おく", okuri: "る", dynamic: false)).notTo(beEmpty())
            }
        }
    }
}
