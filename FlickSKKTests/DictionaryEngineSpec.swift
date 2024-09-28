import Quick
import Nimble

@MainActor
final class DictionaryEngineSpec : QuickSpec, Sendable {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = Bundle(for: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
        }()

    override func spec() {
        MainActor.assumeIsolated {
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
}
