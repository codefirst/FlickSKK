import Quick
import Nimble

class KeyHandlerKanaComposeSpec : KeyHandlerBaseSpec {

    override func spec() {
        var handler : KeyHandler!
        var delegate : MockDelegate!

        beforeEach {
            self.dictionary = SKKDictionary()
            self.dictionary.waitForLoading()
            let (h, d) =  self.create(self.dictionary)
            handler = h
            delegate = d
        }

        let candidates = exacts(["川", "河"])

        context("kana compose") {
            let composeMode = ComposeMode.kanaCompose(kana: "かわ", candidates: candidates)
            it("文字入力(シフトなし)") {
                let m = handler.handle(.char(kana: "ら", shift: false), composeMode: composeMode)
                expect(self.kana(m)).to(equal("かわら"))
            }
            describe("Space") {
                it("partialな候補がある場合") {
                    self.dictionary.partial("かわなんとか", okuri: .none, kanji: "カワナントカ")
                    let m = handler.handle(.space, composeMode: composeMode)
                    _ = self.kanji(m)!
                    if let c = self.candidates(m)?[0] {
                        switch c {
                        case let .partial(kanji: kanji, kana: _):
                            expect(kanji).to(equal("カワナントカ"))
                        default:
                            fail()
                        }

                    } else {
                        fail()
                    }
                }

                it("単語がある場合") {
                    let m = handler.handle(.space, composeMode: composeMode)
                    let (kana, okuri) = self.kanji(m)!
                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal(""))
                    expect(self.candidates(m)).toNot(beEmpty())
                }
                it("単語がない場合") {
                    let m = handler.handle(.space, composeMode: .kanaCompose(kana: "あああ", candidates: []))
                    switch m {
                    case .wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("あああ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .directInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            describe("SkipPartialCandidates") {
                it("partialな候補がある場合はexactまでスキップ") {
                    self.dictionary.partial("かわなんとか", okuri: .none, kanji: "カワナントカ")
                    let m = handler.handle(.skipPartialCandidates, composeMode: composeMode)
                    switch m {
                    case let .kanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: index):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(beNil())
                        expect(candidates).toNot(beEmpty())
                        expect(index).to(equal(1))
                    default:
                        fail()
                    }
                }

                it("partialな候補がなくexactの候補がある場合は通常の変換") {
                    let m = handler.handle(.skipPartialCandidates, composeMode: composeMode)
                    switch m {
                    case let .kanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: index):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(beNil())
                        expect(candidates).toNot(beEmpty())
                        expect(index).to(equal(1))
                    default:
                        fail()
                    }
                }

                it("partial,exactどちらも候補がない場合は登録") {
                    let m = handler.handle(.space, composeMode: .kanaCompose(kana: "あああ", candidates: []))
                    switch m {
                    case .wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("あああ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .directInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            it("Enter") {
                let m = handler.handle(.enter, composeMode: composeMode)
                expect(m == .directInput).to(beTrue())
                expect(delegate.insertedText).to(equal("かわ"))
            }
            describe("Backspace") {
                it("文字がある場合") {
                    let m = handler.handle(.backspace, composeMode: composeMode)
                    expect(self.kana(m)).to(equal("か"))
                }
                it("文字がなくなる場合") {
                    let m = handler.handle(.backspace, composeMode: .kanaCompose(kana: "か", candidates: []))
                    expect(m == .directInput).to(beTrue())
                }
            }
            it("大文字変換") {
                let m = handler.handle(.toggleUpperLower(beforeText: ""), composeMode: .kanaCompose(kana: "foo", candidates: []))
                expect(self.kana(m)).to(equal("foO"))
            }
            it("濁点変換") {
                let m = handler.handle(.toggleDakuten(beforeText: ""), composeMode: .kanaCompose(kana: "か", candidates: []))
                expect(self.kana(m)).to(equal("が"))
            }
            it("入力モード") {
                let m = handler.handle(.inputModeChange(inputMode : .katakana), composeMode: composeMode)
                expect(m == .directInput).to(beTrue())
                expect(delegate.insertedText).to(equal("カワ"))
            }
            it("略語学習") {
                let composeMode = ComposeMode.kanaCompose(kana: "はなやまた", candidates: candidates)
                _ = handler.handle(.inputModeChange(inputMode : .katakana), composeMode: composeMode)
                let xs = self.dictionary.findDynamic("はなや").filter { w in
                    w.kanji == "ハナヤマタ"
                }
                expect(xs.count).to(equal(1))
            }
            describe("シフトあり文字入力") {
                it("単語がある場合") {
                    self.dictionary.partial("かわなんとか", okuri: .none, kanji: "カワナントカ")
                    let m = handler.handle(.char(kana: "い", shift: true), composeMode: composeMode)
                    let (kana, okuri) = self.kanji(m)!
                    let kanjis = self.candidates(m)?.map({ c in c.kanji })

                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal("い"))

                    expect(kanjis).to(contain("乾い"))
                    expect(kanjis).toNot(contain("カワナントカ"))
                }
                it("単語がない場合") {
                    let m = handler.handle(.char(kana: "あ", shift: true), composeMode: composeMode)
                    switch m {
                    case .wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(equal("あ"))
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .directInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            describe("候補選択") {
                it("選択") {
                    let m = handler.handle(.select(index: 0), composeMode: composeMode)
                    expect(delegate.insertedText).to(equal("川"))
                    expect(m == .directInput).to(beTrue())
                    // 学習したものが先頭にくる
                    expect(self.dictionary.find("かわ", okuri: nil)[0]).to(equal("川"))
                }
                it("単語登録モード") {
                    let m = handler.handle(.select(index: 2), composeMode: composeMode)
                    switch m {
                    case .wordRegister(kana: let kana, okuri: let okuri, composeText : let composeText, composeMode : let composeMode):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(beNil())
                        expect(composeText).to(equal(""))
                        expect(composeMode[0] == .directInput).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
        }
    }
}
