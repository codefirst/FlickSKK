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
            let composeMode = ComposeMode.wordRegister(kana: "ろうた", okuri: "け", composeText : "", composeMode: [ .directInput ])

            it("文字入力(シフトなし)") {
                let m = handler.handle(.char(kana: "に", shift: false), composeMode: composeMode)
                switch m {
                case ComposeMode.wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                    expect(kana).to(equal("ろうた"))
                    expect(okuri).to(equal("け"))
                    expect(composeText).to(equal("に"))
                    expect(composeMode[0] == .directInput).to(beTrue())
                default:
                    fail()
                }
            }
            it("Space") {
                let m = handler.handle(.space, composeMode: composeMode)
                switch m {
                case ComposeMode.wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                    expect(kana).to(equal("ろうた"))
                    expect(okuri).to(equal("け"))
                    expect(composeText).to(equal(" "))
                    expect(composeMode[0] == .directInput).to(beTrue())
                default:
                    fail()
                }
            }
            describe("Enter") {
                it("送りなし") {
                    let m = handler.handle(.enter, composeMode:
                        .wordRegister(kana: "まじ", okuri: .none, composeText : "本気", composeMode: [ .directInput ]))
                    expect(m == .directInput).to(beTrue())
                    expect(delegate.insertedText).to(equal("本気"))
                    expect(self.dictionary.find("まじ", okuri: .none)[0]).to(equal("本気"))
                }
                it("送りあり") {
                    let m = handler.handle(.enter, composeMode:
                        .wordRegister(kana: "ろうた", okuri: "け", composeText : "臘長", composeMode: [ .directInput ]))
                    expect(m == .directInput).to(beTrue())
                    expect(delegate.insertedText).to(equal("臘長け"))
                    expect(self.dictionary.find("ろうた", okuri: "k")).to(contain("臘長"))
                }
            }
            describe("Backspace") {
                it("index == 0") {
                    let m = handler.handle(.backspace, composeMode: composeMode)
                    expect(self.kana(m)).to(equal("ろうた"))
                }
                it("index > 0") {
                    let m = handler.handle(.backspace,
                        composeMode: .wordRegister(kana: "まじ", okuri: .none, composeText : "本気", composeMode: [ .directInput ]))
                    switch m {
                    case ComposeMode.wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("まじ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal("本"))
                        expect(composeMode[0] == .directInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            it("大文字変換") {
                let m = handler.handle(.toggleUpperLower(beforeText: ""), composeMode:
                    .wordRegister(kana: "まじ", okuri: .none, composeText : "foo", composeMode: [ .directInput ]))
                switch m {
                case ComposeMode.wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                    expect(kana).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("foO"))
                    expect(composeMode[0] == .directInput).to(beTrue())
                default:
                    fail()
                }
            }
            describe("濁点変換") {
                it("入力中") {
                    let m = handler.handle(.toggleDakuten(beforeText: ""), composeMode:
                        .wordRegister(kana: "まじ", okuri: .none, composeText : "か", composeMode: [ .directInput ]))
                    switch m {
                    case ComposeMode.wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("まじ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal("が"))
                        expect(composeMode[0] == .directInput).to(beTrue())
                    default:
                        fail()
                    }
                }
                it("冒頭") {
                    let m = handler.handle(.toggleDakuten(beforeText: ""), composeMode:
                        .wordRegister(kana: "よ", okuri: "ふ", composeText : "", composeMode: [ .directInput ]))
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
                let m = handler.handle(.inputModeChange(inputMode : .katakana), composeMode: composeMode)
                expect(m == composeMode).to(beTrue())
                expect(delegate.inputMode == .katakana).to(beTrue())
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.char(kana: "い", shift: true), composeMode: composeMode)
                switch m {
                case ComposeMode.wordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
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
