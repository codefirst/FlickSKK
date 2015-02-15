import Quick
import Nimble

class KeyHandlerSpec : QuickSpec, SKKDelegate {

    // delegate
    func insertText(text : String) { self.insertedText += text }
    func deleteBackward() { self.insertedText = self.insertedText.butLast() }
    func composeText(text : String) { }
    func changeInputMode(inputMode: SKKInputMode) {
        self.inputMode = inputMode
    }
    func showCandidates(candidates : [String]?) {}

    // stub variable
    var insertedText = ""
    var inputMode : SKKInputMode = .Hirakana

    override func spec() {
        var handler : KeyHandler!
        let bundle = NSBundle(forClass: self.classForCoder)
        let jisyo = bundle.pathForResource("skk", ofType: "jisyo")
        let dict = SKKDictionary(userDict: "", dicts:[jisyo!])
        dict.waitForLoading()

        beforeEach {
            handler = KeyHandler(delegate: self, dictionary: dict)
            self.insertedText = ""
            self.inputMode = .Hirakana
        }

        func kana(composeMode : ComposeMode)  -> String? {
            switch composeMode {
            case .KanaCompose(kana : let kana, candidates: _):
                return kana
            default:
                return nil
            }
        }

        func kanji(composeMode : ComposeMode) -> (String, String)? {
            switch composeMode {
            case .KanjiCompose(kana: let kana, okuri : let okuri, candidates: _, index: _):
                return (kana, okuri ?? "")
            default:
                return nil
            }
        }

        func candidates(composeMode : ComposeMode) -> [String]? {
            switch composeMode {
            case .KanjiCompose(kana: _, okuri: _, candidates: let candidates, index: _):
                return candidates
            case .KanaCompose(kana: _, candidates: let candidates):
                return candidates
            default:
                return nil
            }
        }

        func index(composeMode: ComposeMode) -> Int? {
            switch composeMode {
            case .KanjiCompose(kana: _, okuri: _, candidates: _, index: let index):
                return index
            default:
                return nil
            }
        }


        context("directInput") {
            it("文字入力(シフトなし)") {
                handler.handle(.Char(kana: "あ", shift: false), composeMode: .DirectInput)
                expect(self.insertedText).to(equal("あ"))
            }
            it("Space") {
                handler.handle(.Space, composeMode: .DirectInput)
                expect(self.insertedText).to(equal(" "))
            }
            it("Enter") {
                handler.handle(.Enter, composeMode: .DirectInput)
                expect(self.insertedText).to(equal("\n"))
            }
            it("Backspace") {
                self.insertedText = "foo"
                handler.handle(.Backspace, composeMode: .DirectInput)
                expect(self.insertedText).to(equal("fo"))
            }
            it("大文字変換") {
                self.insertedText = "foo"
                handler.handle(.ToggleUpperLower(beforeText: "o"), composeMode: .DirectInput)
                expect(self.insertedText).to(equal("foO"))

            }
            it("濁点変換") {
                self.insertedText = "か"
                handler.handle(.ToggleDakuten(beforeText: "か"), composeMode: .DirectInput)
                expect(self.insertedText).to(equal("が"))
            }
            it("入力モード") {
                handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: .DirectInput)
                expect(self.inputMode).to(equal(SKKInputMode.Katakana))
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.Char(kana: "あ", shift: true),  composeMode: .DirectInput)
                expect(self.insertedText).to(equal(""))
                expect(kana(m)).to(equal("あ"))
                expect(candidates(m)).toNot(beEmpty())
            }
        }

        context("kana compose") {
            let composeMode = ComposeMode.KanaCompose(kana: "かわ", candidates: ["川", "河"])
            it("文字入力(シフトなし)") {
                let m = handler.handle(.Char(kana: "ら", shift: false), composeMode: composeMode)
                expect(kana(m)).to(equal("かわら"))
            }
            describe("Space") {
                it("単語がある場合") {
                    let m = handler.handle(.Space, composeMode: composeMode)
                    let (kana, okuri) = kanji(m)!
                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal(""))
                    expect(candidates(m)).toNot(beEmpty())
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
                expect(self.insertedText).to(equal("かわ"))
            }
            describe("Backspace") {
                it("文字がある場合") {
                    let m = handler.handle(.Backspace, composeMode: composeMode)
                    expect(kana(m)).to(equal("か"))
                }
                it("文字がない場合") {
                    let m = handler.handle(.Backspace, composeMode: .KanaCompose(kana: "", candidates: []))
                    expect(m == .DirectInput).to(beTrue())
                }
            }
            it("大文字変換") {
                let m = handler.handle(.ToggleUpperLower(beforeText: ""), composeMode: .KanaCompose(kana: "foo", candidates: []))
                expect(kana(m)).to(equal("foO"))
            }
            it("濁点変換") {
                let m = handler.handle(.ToggleDakuten(beforeText: ""), composeMode: .KanaCompose(kana: "か", candidates: []))
                expect(kana(m)).to(equal("が"))
            }
            it("入力モード") {
                let m = handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: composeMode)
                expect(m == .DirectInput).to(beTrue())
                expect(self.insertedText).to(equal("カワ"))
            }
            describe("シフトあり文字入力") {
                it("単語がある場合") {
                    let m = handler.handle(.Char(kana: "い", shift: true), composeMode: composeMode)
                    let (kana, okuri) = kanji(m)!
                    expect(kana).to(equal("かわ"))
                    expect(okuri).to(equal("い"))
                    expect(candidates(m)).toNot(beEmpty())
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
                    expect(self.insertedText).to(equal("川"))
                    expect(m == .DirectInput).to(beTrue())
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

        context("kanji compose") {
            let composeMode = ComposeMode.KanjiCompose(kana: "かわ", okuri: .None, candidates: ["川", "河"], index: 0)

            it("文字入力(シフトなし)") {
                let m = handler.handle(.Char(kana: "に", shift: false), composeMode: composeMode)
                expect(self.insertedText).to(equal("川に"))
                expect(m == .DirectInput).to(beTrue())
            }
            describe("Space") {
                it("単語がある場合") {
                    let m = handler.handle(.Space, composeMode: composeMode)
                    let (kana, okuri) = kanji(m)!
                    expect(index(m)).to(equal(1))
                }
                it("単語がない場合") {
                    let m = handler.handle(.Space, composeMode: .KanjiCompose(kana: "かわ", okuri: .None, candidates: ["川", "河"], index: 1))
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
            it("Enter") {
                let m = handler.handle(.Enter, composeMode: composeMode)
                expect(m == .DirectInput).to(beTrue())
                expect(self.insertedText).to(equal("川"))
            }
            describe("Backspace") {
                it("index == 0") {
                    let m = handler.handle(.Backspace, composeMode: composeMode)
                    expect(kana(m)).to(equal("かわ"))
                }
                it("index > 0") {
                    let m = handler.handle(.Backspace, composeMode: ComposeMode.KanjiCompose(kana: "かわ", okuri: .None, candidates: ["川", "河"], index: 1))
                    expect(index(m)).to(equal(0))
                }
            }
            it("大文字変換") {
                // FIXME: 辞書に適当な単語が登録されていないのでテストしにくい
            }
            it("濁点変換") {
                let m = handler.handle(.ToggleDakuten(beforeText: ""),
                    composeMode: ComposeMode.KanjiCompose(kana: "さわ",
                        okuri: "き",
                        candidates: ["foo","bar"], index: 1))
                let (kana, okuri) = kanji(m)!
                expect(kana).to(equal("さわ"))
                expect(okuri).to(equal("ぎ"))
                expect(candidates(m)).toNot(beEmpty())
                expect(index(m)).to(equal(0))
            }
            it("入力モード") {
                let m = handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: composeMode)
                expect(m == composeMode).to(beTrue())
                expect(self.inputMode == .Katakana).to(beTrue())
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.Char(kana: "い", shift: true), composeMode: composeMode)
                expect(self.insertedText).to(equal("川"))
                expect(kana(m)).to(equal("い"))
            }
            describe("候補選択") {
                it("選択") {
                    let m = handler.handle(.Select(index: 0), composeMode: composeMode)
                    expect(self.insertedText).to(equal("川"))
                    expect(m == .DirectInput).to(beTrue())
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
                    expect(self.insertedText).to(equal("本気"))
                    expect(dict.find("まじ", okuri: .None)).to(contain("本気"))
                }
                it("送りあり") {
                    let m = handler.handle(.Enter, composeMode:
                        .WordRegister(kana: "ろうた", okuri: "け", composeText : "臘長", composeMode: [ .DirectInput ]))
                    expect(m == .DirectInput).to(beTrue())
                    expect(self.insertedText).to(equal("臘長け"))
                    expect(dict.find("ろうた", okuri: "k")).to(contain("臘長"))
                }
            }
            describe("Backspace") {
                it("index == 0") {
                    let m = handler.handle(.Backspace, composeMode: composeMode)
                    expect(kana(m)).to(equal("ろうた"))
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
            it("濁点変換") {
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
            it("入力モード") {
                let m = handler.handle(.InputModeChange(inputMode : .Katakana), composeMode: composeMode)
                expect(m == composeMode).to(beTrue())
                expect(self.inputMode == .Katakana).to(beTrue())
            }
            it("シフトあり文字入力") {
                let m = handler.handle(.Char(kana: "い", shift: true), composeMode: composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("ろうた"))
                    expect(okuri).to(equal("け"))
                    expect(composeText).to(equal(""))
                    expect(kana(xs[0])).to(equal("い"))
                default:
                    fail()
                }
            }
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
                okuri: .None, composeText : "か", composeMode: [ .KanjiCompose(kana: "やま", okuri : .None, candidates: ["山"], index: 0)])
            it("Enter") {
                let m = handler.handle(.Enter, composeMode : composeMode)
                switch m {
                case ComposeMode.WordRegister(kana: let k, okuri: let okuri, composeText : let composeText, composeMode : let xs):
                    expect(k).to(equal("まじ"))
                    expect(okuri).to(beNil())
                    expect(composeText).to(equal("か山"))
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
                    expect(self.insertedText).to(equal(""))
                    expect(kana(xs[0])).to(equal("あ"))
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
                    expect(self.insertedText).to(equal(""))
                    expect(xs[0] == .DirectInput).to(beTrue())
                default:
                    fail()
                }
            }
        }
    }
}