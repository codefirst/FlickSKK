import Quick
import Nimble

class KeyHandlerKanjiComposeSpec : KeyHandlerBaseSpec {

    override func spec() {
        var handler : KeyHandler!
        var delegate : MockDelegate!

        beforeEach {
            let (h, d) =  self.create(self.dictionary)
            handler = h
            delegate = d
        }

        let candidates = exacts(["川", "河"])
        let candidatesWithOkuri = exacts(["居る", "入る"])

        context("kanji compose") {
            let composeMode = ComposeMode.kanjiCompose(kana: "かわ", okuri: .none, candidates: candidates, index: 0)

            it("文字入力(シフトなし)") {
                let m = handler.handle(.char(kana: "に", shift: false), composeMode: composeMode)
                expect(delegate.insertedText).to(equal("川に"))
                expect(m == .directInput).to(beTrue())
                // 学習したものが先頭にくる
                expect(self.dictionary.find("かわ", okuri: nil)[0]).to(equal("川"))
            }
            describe("Space") {
                it("単語がある場合") {
                    let m = handler.handle(.space, composeMode: composeMode)
                    let (kana, okuri) = self.kanji(m)!
                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal(""))
                    expect(self.index(m)).to(equal(1))
                }
                it("送り仮名がある場合") {
                    let m = handler.handle(.space, composeMode: ComposeMode.kanjiCompose(kana: "い", okuri: "る",
                        candidates: candidatesWithOkuri, index: 0))
                    let (kana, okuri) = self.kanji(m)!
                    expect(kana).to(equal("い"))
                    expect(okuri).to(equal("る"))
                    expect(self.index(m)).to(equal(1))
                }
                it("単語がない場合") {
                    let m = handler.handle(.space, composeMode: .kanjiCompose(kana: "かわ", okuri: .none, candidates: candidates, index: 1))
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
            describe("SkipPartialCandidates") {
                it("partialな候補がある場合はexactまでスキップ") {
                    let candidates: [Candidate] = [.partial(kanji: "かわなんとか", kana: "カワナントカ0"), .partial(kanji: "かわなんとか", kana: "カワナントカ1")] + self.exacts(["川", "河"])
                    let m = handler.handle(.skipPartialCandidates, composeMode: ComposeMode.kanjiCompose(kana: "かわ", okuri: .none, candidates: candidates, index: 0))
                    switch m {
                    case let .kanjiCompose(kana: kana, okuri: okuri, candidates: candidates, index: index):
                        expect(kana).to(equal("かわ"))
                        expect(okuri).to(beNil())
                        expect(candidates).toNot(beEmpty())
                        expect(index).to(equal(2))
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
                    let m = handler.handle(.skipPartialCandidates, composeMode: .kanjiCompose(kana: "かわ", okuri: .none, candidates: candidates, index: 1))
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
            it("Enter") {
                let m = handler.handle(.enter, composeMode: composeMode)
                expect(m == .directInput).to(beTrue())
                expect(delegate.insertedText).to(equal("川"))
                // 学習したものが先頭にくる
                expect(self.dictionary.find("かわ", okuri: nil)[0]).to(equal("川"))
            }
            describe("Backspace") {
                it("index == 0") {
                    let m = handler.handle(.backspace, composeMode: composeMode)
                    expect(self.kana(m)).to(equal("かわ"))
                }
                it("index > 0") {
                    let m = handler.handle(.backspace, composeMode: ComposeMode.kanjiCompose(kana: "かわ", okuri: .none, candidates: candidates, index: 1))
                    expect(self.index(m)).to(equal(0))
                }
            }
            it("大文字変換") {
                // FIXME: 辞書に適当な単語が登録されていないのでテストしにくい
            }
            it("濁点変換") {
                let m = handler.handle(.toggleDakuten(beforeText: ""),
                    composeMode: ComposeMode.kanjiCompose(kana: "さわ",
                        okuri: "き",
                        candidates: candidates, index: 1))
                let (kana, okuri) = self.kanji(m)!
                expect(kana).to(equal("さわ"))
                expect(okuri).to(equal("ぎ"))
                expect(self.candidates(m)).toNot(beEmpty())
                expect(self.index(m)).to(equal(0))
            }
            it("入力モード") {
                let m = handler.handle(.inputModeChange(inputMode : .katakana), composeMode: composeMode)
                expect(m == composeMode).to(beTrue())
                expect(delegate.inputMode == .katakana).to(beTrue())
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.char(kana: "い", shift: true), composeMode: composeMode)
                expect(delegate.insertedText).to(equal("川"))
                expect(self.kana(m)).to(equal("い"))
            }
            describe("候補選択") {
                it("選択") {
                    let m = handler.handle(.select(index: 0), composeMode: composeMode)
                    expect(delegate.insertedText).to(equal("川"))
                    expect(m == .directInput).to(beTrue())
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
            describe("学習") {
                it("送りなし") {
                    _ = handler.handle(.select(index: 0), composeMode: composeMode)
                    // 学習したものが先頭にくる
                    expect(self.dictionary.find("かわ", okuri: nil)[0]).to(equal("川"))
                }
                it("送りあり") {
                    let composeMode = ComposeMode.kanjiCompose(kana: "い", okuri: "る", candidates: candidatesWithOkuri, index: 0)
                    _ = handler.handle(.select(index: 1), composeMode: composeMode)

                    // 学習したものが先頭にくる
                    let xs = self.dictionary.find("い", okuri: "r")
                    expect(xs).notTo(beEmpty())

                    // 送り仮名は学習しない
                    expect(xs[0]).to(equal("入"))
                }
            }
        }

    }
}
