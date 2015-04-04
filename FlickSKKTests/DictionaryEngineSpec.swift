import Quick
import Nimble

class DictionaryEngineSpec : QuickSpec {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = NSBundle(forClass: self.classForCoder)
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
                let xs = dictionaryEngine.find("おく", okuri: "る", dynamic: false)
            }
        }
    }
}
