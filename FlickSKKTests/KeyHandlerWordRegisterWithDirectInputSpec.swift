import Quick
import Nimble

class KeyHandlerWordRegisterWithDirectInputSpec : KeyHandlerBaseSpec {

    override func spec() {
        var handler : KeyHandler!
        var delegate : MockDelegate!

        beforeEach {
            let (h, d) =  self.create(self.dictionary)
            handler = h
            delegate = d
        }

        context("word register with direct mode") {
            let composeMode = ComposeMode.WordRegister(kana: "ろうた", okuri: "け", composeText : "", composeMode: [ .DirectInput ])

            it("文字入力(シフトなし)") {
                let m = handler.handle(.Char(kana: "に", shift: false), composeMode: composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                    expect(kana).to(equal("ろうた"))
                    expect(okuri).to(equal("け"))
                    expect(composeText).to(equal("に"))
                    expect(composeMode[0] == .DirectInput).to(beTrue())
                default:
                    fail()
                }
            }
            it("Space") {
                let m = handler.handle(.Space, composeMode: composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                    expect(kana).to(equal("ろうた"))
                    expect(okuri).to(equal("け"))
                    expect(composeText).to(equal(" "))
                    expect(composeMode[0] == .DirectInput).to(beTrue())
                default:
                    fail()
                }
            }
            describe("Enter") {
                it("送りなし") {
                    let m = handler.handle(.Enter, composeMode:
                        .WordRegister(kana: "まじ", okuri: .None, composeText : "本気", composeMode: [ .DirectInput ]))
                    expect(m == .DirectInput).to(beTrue())
                    expect(delegate.insertedText).to(equal("本気"))
                    expect(self.dictionary.find("まじ", okuri: .None)[0]).to(equal("本気"))
                }
                it("送りあり") {
                    let m = handler.handle(.Enter, composeMode:
                        .WordRegister(kana: "ろうた", okuri: "け", composeText : "臘長", composeMode: [ .DirectInput ]))
                    expect(m == .DirectInput).to(beTrue())
                    expect(delegate.insertedText).to(equal("臘長け"))
                    expect(self.dictionary.find("ろうた", okuri: "k")).to(contain("臘長"))
                }
            }
            describe("Backspace") {
                it("index == 0") {
                    let m = handler.handle(.Backspace, composeMode: composeMode)
                    expect(self.kana(m)).to(equal("ろうた"))
                }
                it("index > 0") {
                    let m = handler.handle(.Backspace,
                        composeMode: .WordRegister(kana: "まじ", okuri: .None, composeText : "本気", composeMode: [ .DirectInput ]))
                    switch m {
                    case ComposeMode.WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("まじ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal("本"))
                        expect(composeMode[0] == .DirectInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            it("大文字変換") {
                let m = handler.handle(.ToggleUpperLower(beforeText: ""), composeMode:
                    .WordRegister(kana: "まじ", okuri: .None, composeText : "foo", composeMode: [ .DirectInput ]))
                switch m {
                case ComposeMode.WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                    expect(kana).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("foO"))
                    expect(composeMode[0] == .DirectInput).to(beTrue())
                default:
                    fail()
                }
            }
            describe("濁点変換") {
                it("入力中") {
                    let m = handler.handle(.ToggleDakuten(beforeText: ""), composeMode:
                        .WordRegister(kana: "まじ", okuri: .None, composeText : "か", composeMode: [ .DirectInput ]))
                    switch m {
                    case ComposeMode.WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("まじ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal("が"))
                        expect(composeMode[0] == .DirectInput).to(beTrue())
                    default:
                        fail()
                    }
                }
                it("冒頭") {
                    let m = handler.handle(.ToggleDakuten(beforeText: ""), composeMode:
                        .WordRegister(kana: "よ", okuri: "ふ", composeText : "", composeMode: [ .DirectInput ]))
                    if let (kana, okuri) = self.kanji(m) {
                        expect(kana).to(equal("よ"))
                        expect(okuri).to(equal("ぶ"))
                        expect(self.candidates(m)).toNot(beEmpty())
                        expect(self.index(m)).to(equal(0))
                    } else {
                        fail()
                    }
                }
            }
            it("入力モード") {
                let m = handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: composeMode)
                expect(m == composeMode).to(beTrue())
                expect(delegate.inputMode == .Katakana).to(beTrue())
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.Char(kana: "い", shift: true), composeMode: composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("ろうた"))
                    expect(okuri).to(equal("け"))
                    expect(composeText).to(equal(""))
                    expect(self.kana(xs[0])).to(equal("い"))
                default:
                    fail()
                }
            }
        }
    }
}
