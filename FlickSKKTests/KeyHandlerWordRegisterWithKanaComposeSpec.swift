import Quick
import Nimble

class KeyHandlerWordRegisterWithKanaComposeSpec : KeyHandlerBaseSpec {

    override func spec() {
        var handler : KeyHandler!
        var delegate : MockDelegate!

        beforeEach {
            let (h, d) =  self.create(self.dictionary)
            handler = h
            delegate = d
        }

        context("word register with kana mode") {
            let composeMode = ComposeMode.WordRegister(kana: "まじ",
                okuri: .None, composeText : "か", composeMode: [ .KanaCompose(kana: "あああ", candidates: []) ])
            it("Enter") {
                let m = handler.handle(.Enter, composeMode : composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("かあああ"))
                default:
                    fail()
                }
            }
            it("InputModeChange") {
                let m = handler.handle(.InputModeChange(inputMode: .Katakana), composeMode : composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("かアアア"))
                default:
                    fail()
                }
            }
        }

        context("word register with kanji mode") {
            let composeMode = ComposeMode.WordRegister(kana: "まじ",
                okuri: .None, composeText : "か", composeMode: [ .KanjiCompose(kana: "やま", okuri : .None, candidates: self.exacts(["山"]), index: 0)])
            it("Enter") {
                let m = handler.handle(.Enter, composeMode : composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("か山"))
                    // 学習したものが先頭にくる
                    expect(self.dictionary.find("やま", okuri: nil)[0]).to(equal("山"))
                default:
                    fail()
                }
            }
            it("シフト付き") {
                let m = handler.handle(.Char(kana: "あ", shift: true), composeMode : composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("か山"))
                    expect(delegate.insertedText).to(equal(""))
                    expect(self.kana(xs[0])).to(equal("あ"))
                default:
                    fail()
                }
            }
            it("シフトなし") {
                let m = handler.handle(.Char(kana: "あ", shift: false), composeMode : composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("か山あ"))
                    expect(delegate.insertedText).to(equal(""))
                    expect(xs[0] == .DirectInput).to(beTrue())
                default:
                    fail()
                }
            }
        }
    }
}
