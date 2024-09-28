import Quick
import Nimble

@MainActor
final class TextEngineSpec : QuickSpec, Sendable {
    lazy var dictionary : SKKDictionary = {
        DictionarySettings.bundle = Bundle(for: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()
        return dict
    }()

    override func spec() {
        MainActor.assumeIsolated {
            var target : TextEngine!
            var delegate : MockDelegate!

            beforeEach { @MainActor in
                delegate = MockDelegate()
                let dictionaryEngine = DictionaryEngine(dictionary: self.dictionary)
                target = TextEngine(delegate: delegate, dictionary: dictionaryEngine)
            }

            describe("#insertPartial") {
                beforeEach { @MainActor in
                    _ = target.insertPartial("ハナヤマタ", kana: "はなやまた", status: TextEngine.Status.topLevel)
                }

                it("挿入される") { @MainActor in
                    expect(delegate.insertedText).to(equal("ハナヤマタ"))
                }

                it("補完できる") { @MainActor in
                    let xs = self.dictionary.findDynamic("はなや").filter { w in w.kanji == "ハナヤマタ" }
                    expect(xs.count).to(equal(1))
                }
            }
        }
    }
}
