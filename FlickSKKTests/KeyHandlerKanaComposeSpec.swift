import Quick
import Nimble

class KeyHandlerKanaComposeSpec : KeyHandlerBaseSpec {

    override func spec() {
        var handler : KeyHandler!
        var delegate : MockDelegate!

        beforeEach {
            let (h, d) =  self.create(self.dictionary)
            handler = h
            delegate = d
        }

        let candidates = exacts(["川", "河"])

        context("kana compose") {
            let composeMode = ComposeMode.KanaCompose(kana: "かわ", candidates: candidates)
            it("文字入力(シフトなし)") {
                let m = handler.handle(.Char(kana: "ら", shift: false), composeMode: composeMode)
                expect(self.kana(m)).to(equal("かわら"))
            }
            describe("Space") {
                it("単語がある場合") {
                    let m = handler.handle(.Space, composeMode: composeMode)
                    let (kana, okuri) = self.kanji(m)!
                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal(""))
                    expect(self.candidates(m)).toNot(beEmpty())
                }
                it("単語がない場合") {
                    let m = handler.handle(.Space, composeMode: .KanaCompose(kana: "あああ", candidates: []))
                    switch m {
                    case .WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("あああ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .DirectInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            it("Enter") {
                let m = handler.handle(.Enter, composeMode: composeMode)
                expect(m == .DirectInput).to(beTrue())
                expect(delegate.insertedText).to(equal("かわ"))
            }
            describe("Backspace") {
                it("文字がある場合") {
                    let m = handler.handle(.Backspace, composeMode: composeMode)
                    expect(self.kana(m)).to(equal("か"))
                }
                it("文字がなくなる場合") {
                    let m = handler.handle(.Backspace, composeMode: .KanaCompose(kana: "か", candidates: []))
                    expect(m == .DirectInput).to(beTrue())
                }
            }
            it("大文字変換") {
                let m = handler.handle(.ToggleUpperLower(beforeText: ""), composeMode: .KanaCompose(kana: "foo", candidates: []))
                expect(self.kana(m)).to(equal("foO"))
            }
            it("濁点変換") {
                let m = handler.handle(.ToggleDakuten(beforeText: ""), composeMode: .KanaCompose(kana: "か", candidates: []))
                expect(self.kana(m)).to(equal("が"))
            }
            it("入力モード") {
                let m = handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: composeMode)
                expect(m == .DirectInput).to(beTrue())
                expect(delegate.insertedText).to(equal("カワ"))
            }
            it("略語学習") {
                let composeMode = ComposeMode.KanaCompose(kana: "はなやまた", candidates: candidates)
                let m = handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: composeMode)
                let xs = self.dictionary.findDynamic("はなや").filter { w in
                    w.kanji == "ハナヤマタ"
                }
                expect(xs.count).to(equal(1))
            }
            describe("シフトあり文字入力") {
                it("単語がある場合") {
                    let m = handler.handle(.Char(kana: "い", shift: true), composeMode: composeMode)
                    let (kana, okuri) = self.kanji(m)!
                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal("い"))
                    expect(self.candidates(m)).toNot(beEmpty())
                }
                it("単語がない場合") {
                    let m = handler.handle(.Char(kana: "あ", shift: true), composeMode: composeMode)
                    switch m {
                    case .WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(equal("あ"))
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .DirectInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            describe("候補選択") {
                it("選択") {
                    let m = handler.handle(.Select(index: 0), composeMode: composeMode)
                    expect(delegate.insertedText).to(equal("川"))
                    expect(m == .DirectInput).to(beTrue())
                    // 学習したものが先頭にくる
                    expect(self.dictionary.find("かわ", okuri: nil)[0]).to(equal("川"))
                }
                it("単語登録モード") {
                    let m = handler.handle(.Select(index: 2), composeMode: composeMode)
                    switch m {
                    case .WordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .DirectInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
        }
    }
}