import Quick
import Nimble

class KeyHandlerDirectInputSpec : KeyHandlerBaseSpec {

    override func spec() {
        var handler : KeyHandler!
        var delegate : MockDelegate!

        beforeEach {
            let (h, d) =  self.create(self.dictionary)
            handler = h
            delegate = d
        }

        context("directInput") {
            it("文字入力(シフトなし)") {
                _ = handler.handle(.char(kana: "あ", shift: false), composeMode: .directInput)
                expect(delegate.insertedText).to(equal("あ"))
            }
            it("Space") {
                _ = handler.handle(.space, composeMode: .directInput)
                expect(delegate.insertedText).to(equal(" "))
            }
            it("Enter") {
                _ = handler.handle(.enter, composeMode: .directInput)
                expect(delegate.insertedText).to(equal("\n"))
            }
            it("Backspace") {
                delegate.insertedText = "foo"
                _ = handler.handle(.backspace, composeMode: .directInput)
                expect(delegate.insertedText).to(equal("fo"))
            }
            it("大文字変換") {
                delegate.insertedText = "foo"
                _ = handler.handle(.toggleUpperLower(beforeText: "o"), composeMode: .directInput)
                expect(delegate.insertedText).to(equal("foO"))

            }
            it("濁点変換") {
                delegate.insertedText = "か"
                _ = handler.handle(.toggleDakuten(beforeText: "か"), composeMode: .directInput)
                expect(delegate.insertedText).to(equal("が"))
            }
            it("入力モード") {
                _ = handler.handle(.inputModeChange(inputMode : .katakana), composeMode: .directInput)
                expect(delegate.inputMode).to(equal(SKKInputMode.katakana))
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.char(kana: "あ", shift: true),  composeMode: .directInput)
                expect(delegate.insertedText).to(equal(""))
                expect(self.kana(m)).to(equal("あ"))
                expect(self.candidates(m)).toNot(beEmpty())
            }
        }
    }
}
