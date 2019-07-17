//
//  SKKSessionSpec.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/08.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Quick
import Nimble

class SKKEngineSpec : QuickSpec, SKKDelegate {
    // delegate
    func insertText(_ text : String) { self.insertedText += text }
    func deleteBackward() {}
    func composeText(_ text : String, currentCandidate: Candidate?) { self.currentComposeText = text }
    func changeInputMode(_ inputMode: SKKInputMode) {}
    func showCandidates(_ candidates: [Candidate]?) { self.candidates = candidates }

    // stub variable
    var insertedText = ""
    var currentComposeText = ""
    var candidates: [Candidate]? = nil

    override func spec() {
        var engine : SKKEngine!
        DictionarySettings.bundle =  Bundle(for: self.classForCoder)
        let dict = SKKDictionary()
        dict.waitForLoading()

        beforeEach {
            engine = SKKEngine(delegate: self, dictionary: dict)
            self.insertedText = ""
        }

        context("hirakana mode") {
            describe("ひらかな input") {
                it("insert text") {
                    engine.handle(.char(kana: "あ", shift: false))
                    engine.handle(.char(kana: "い", shift: false))
                    engine.handle(.char(kana: "う", shift: false))
                    expect(self.insertedText).to(equal("あいう"))
                }
                it("convert kanji") {
                    engine.handle(.char(kana: "や", shift: true))
                    engine.handle(.char(kana: "ま", shift: false))
                    expect(self.currentComposeText).to(equal("▽やま"))
                    engine.handle(.space)
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("山"))
                }
                it("convert kanji with okuri") {
                    engine.handle(.char(kana: "あ", shift: true))
                    engine.handle(.char(kana: "る", shift: true))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("荒る"))
                }
                context("with dakuten") {
                    it("convert kanji on compose mode") {
                        engine.handle(.char(kana: "か", shift: true))
                        engine.handle(.char(kana: "ん", shift: false))
                        engine.handle(.char(kana: "し", shift: true))
                        expect(self.currentComposeText).to(equal("▼かん*し"))
                        engine.handle(.toggleDakuten(beforeText: ""))
                        expect(self.currentComposeText).to(equal("▼かん*じ"))
                        engine.handle(.enter)
                        expect(self.insertedText).to(equal("感じ"))
                    }
                    it("convert kanji on register mode") {
                        engine.handle(.char(kana: "わ", shift: true))
                        engine.handle(.char(kana: "れ", shift: false))
                        engine.handle(.char(kana: "ら", shift: false))
                        engine.handle(.char(kana: "か", shift: true))
                        engine.handle(.toggleDakuten(beforeText: ""))
                        engine.handle(.enter)
                        expect(self.insertedText).to(equal("我等が"))
                    }
                    it("convert kanji without dakuten") {
                        engine.handle(.char(kana: "わ", shift: true))
                        engine.handle(.char(kana: "り", shift: false))
                        engine.handle(.char(kana: "き", shift: true))
                        engine.handle(.toggleDakuten(beforeText: ""))
                        engine.handle(.toggleDakuten(beforeText: ""))
                        engine.handle(.enter)
                        expect(self.insertedText).to(equal("割き"))
                    }
                }

                it("toggle dakuten") {
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.toggleDakuten(beforeText: "かか"))
                    expect(self.insertedText).to(equal("かかが"))
                }
            }
            describe("number input") {
                it("insert text") {
                    engine.handle(.char(kana: "1", shift: false))
                    engine.handle(.char(kana: "2", shift: false))
                    engine.handle(.char(kana: "3", shift: false))
                    expect(self.insertedText).to(equal("123"))
                }
                it("convert kanji") {
                    engine.handle(.char(kana: "1", shift: true))
                    engine.handle(.char(kana: "2", shift: false))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("12"))
                }
                it("ignore okuri for number") {
                    engine.handle(.char(kana: "1", shift: true))
                    engine.handle(.char(kana: "2", shift: true))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("2"))
                }
            }
            describe("alphabet input") {
                it("insert text") {
                    engine.handle(.char(kana: "a", shift: false))
                    engine.handle(.char(kana: "b", shift: false))
                    engine.handle(.char(kana: "c", shift: false))
                    expect(self.insertedText).to(equal("abc"))
                }
                it("convert kanji") {
                    engine.handle(.char(kana: "a", shift: true))
                    engine.handle(.char(kana: "b", shift: false))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("ab"))
                }
                it("ignore okuri for alphabet") {
                    engine.handle(.char(kana: "a", shift: true))
                    engine.handle(.char(kana: "b", shift: true))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("b"))
                }
                it("toggle upper/lower") {
                    engine.handle(.char(kana: "a", shift: false))
                    engine.handle(.char(kana: "b", shift: false))
                    engine.handle(.toggleUpperLower(beforeText: "ab"))
                    expect(self.insertedText).to(equal("abB"))
                }
            }
            describe("「っ」送り仮名変換") {
                it("can convert 「はいった」") {
                    engine.handle(.char(kana: "は", shift: true))
                    engine.handle(.char(kana: "い", shift: false))
                    engine.handle(.char(kana: "つ",  shift: false))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.char(kana: "た", shift: true))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("入った"))
                }
                it("can convert 「はいっ」") {
                    engine.handle(.char(kana: "は", shift: true))
                    engine.handle(.char(kana: "い", shift: false))
                    engine.handle(.char(kana: "つ", shift: true))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("入っ"))
                }
                it("can convert 「ひっぱる」"){
                    engine.handle(.char(kana: "ひ", shift: true))
                    engine.handle(.char(kana: "つ", shift: false))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.char(kana: "は", shift: true))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("引っぱ"))
                }

                it("can convert 「ばっする」"){
                    engine.handle(.char(kana: "は", shift: true))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.char(kana: "つ", shift: false))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.char(kana: "す", shift: true))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("罰す"))
                }
            }
            describe("dictionary") {
                it("can register dakuten kana") {
                    engine.handle(.char(kana: "か", shift: true))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.space)
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.toggleDakuten(beforeText: ""))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("がか\n"))

                    self.insertedText = ""

                    engine.handle(.char(kana: "か", shift: true))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.space)
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("が"))
                }
                it("can register word with okuri") {
                    // かかk を辞書に登録する
                    engine.handle(.char(kana: "か", shift: true))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.char(kana: "か", shift: true))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("かかか\n"))
                    self.insertedText = ""

                    engine.handle(.char(kana: "か", shift: true))
                    engine.handle(.char(kana: "か", shift: false))
                    engine.handle(.char(kana: "か", shift: true))
                    engine.handle(.enter)
                    expect(self.insertedText).to(equal("かか"))
                }
            }
        }
    }
}
