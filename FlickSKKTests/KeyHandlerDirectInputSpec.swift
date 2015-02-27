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
                handler.handle(.Char(kana: "あ", shift: false), composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal("あ"))
            }
            it("Space") {
                handler.handle(.Space, composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal(" "))
            }
            it("Enter") {
                handler.handle(.Enter, composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal("\n"))
            }
            it("Backspace") {
                delegate.insertedText = "foo"
                handler.handle(.Backspace, composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal("fo"))
            }
            it("大文字変換") {
                delegate.insertedText = "foo"
                handler.handle(.ToggleUpperLower(beforeText: "o"), composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal("foO"))

            }
            it("濁点変換") {
                delegate.insertedText = "か"
                handler.handle(.ToggleDakuten(beforeText: "か"), composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal("が"))
            }
            it("入力モード") {
                handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: .DirectInput)
                expect(delegate.inputMode).to(equal(SKKInputMode.Katakana))
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.Char(kana: "あ", shift: true),  composeMode: .DirectInput)
                expect(delegate.insertedText).to(equal(""))
                expect(self.kana(m)).to(equal("あ"))
                expect(self.candidates(m)).toNot(beEmpty())
            }
        }
    }
}