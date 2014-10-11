//
//  SKKSessionSpec.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/08.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Quick
import Nimble

class SKKSessionSpec : QuickSpec, SKKDelegate {
    
    // delegate
    func insertText(text : String) { self.insertedText += text }
    func deleteBackward() {}
    func composeText(text : String) { self.currentComposeText = text }
    func showCandidates(candidates : [String]?) {}
    
    // stub variable
    var insertedText = ""
    var currentComposeText = ""
    
    override func spec() {
        var session : SKKSession!
        let jisyo = NSBundle.mainBundle().pathForResource("skk", ofType: "jisyo")
        let dict = SKKDictionary(userDict: "", dicts:[jisyo!])
        dict.waitForLoading()
        
        beforeEach {
            session = SKKSession(delegate: self, dict: dict)
            self.insertedText = ""
        }
        
        context("hirakana mode") {
            describe("ひらかな input") {
                it("insert text") {
                    session.handle(.Char(kana: "あ", roman: "a", shift: false))
                    session.handle(.Char(kana: "い", roman: "i", shift: false))
                    session.handle(.Char(kana: "う", roman: "u", shift: false))
                    expect(self.insertedText).to(equal("あいう"))
                }
                it("convert kanji") {
                    session.handle(.Char(kana: "や", roman: "ya", shift: true))
                    session.handle(.Char(kana: "ま", roman: "ma", shift: false))
                    expect(self.currentComposeText).to(equal("▽やま"))
                    session.handle(.Space)
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("山"))
                }
                it("convert kanji with okuri") {
                    session.handle(.Char(kana: "あ", roman: "a", shift: true))
                    session.handle(.Char(kana: "る", roman: "ru", shift: true))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("荒る"))
                }
                context("with dakuten") {
                    it("convert kanji on compose mode") {
                        session.handle(.Char(kana: "か", roman: "ka", shift: true))
                        session.handle(.Char(kana: "ん", roman: "nn", shift: false))
                        session.handle(.Char(kana: "し", roman: "si", shift: true))
                        expect(self.currentComposeText).to(equal("▼関し"))
                        session.handle(.ToggleDakuten(beforeText: ""))
                        expect(self.currentComposeText).to(equal("▼感じ"))
                        session.handle(.Enter)
                        expect(self.insertedText).to(equal("感じ"))
                    }
                    it("convert kanji on register mode") {
                        session.handle(.Char(kana: "わ", roman: "wa", shift: true))
                        session.handle(.Char(kana: "れ", roman: "re", shift: false))
                        session.handle(.Char(kana: "ら", roman: "ra", shift: false))
                        session.handle(.Char(kana: "か", roman: "ka", shift: true))
                        session.handle(.ToggleDakuten(beforeText: ""))
                        session.handle(.Enter)
                        expect(self.insertedText).to(equal("我等が"))
                    }
                    it("convert kanji without dakuten") {
                        session.handle(.Char(kana: "わ", roman: "wa", shift: true))
                        session.handle(.Char(kana: "り", roman: "ri", shift: false))
                        session.handle(.Char(kana: "き", roman: "ki", shift: true))
                        session.handle(.ToggleDakuten(beforeText: ""))
                        session.handle(.ToggleDakuten(beforeText: ""))
                        session.handle(.Enter)
                        expect(self.insertedText).to(equal("割き"))
                    }
                }
                
                it("toggle dakuten") {
                    session.handle(.Char(kana: "か", roman: "ka", shift: false))
                    session.handle(.Char(kana: "か", roman: "ka", shift: false))
                    session.handle(.ToggleDakuten(beforeText: "かか"))
                    expect(self.insertedText).to(equal("かかが"))
                }
            }
            describe("number input") {
                it("insert text") {
                    session.handle(.Char(kana: "1", roman: "", shift: false))
                    session.handle(.Char(kana: "2", roman: "", shift: false))
                    session.handle(.Char(kana: "3", roman: "", shift: false))
                    expect(self.insertedText).to(equal("123"))
                }
                it("convert kanji") {
                    session.handle(.Char(kana: "1", roman: "", shift: true))
                    session.handle(.Char(kana: "2", roman: "", shift: false))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("12"))
                }
                it("ignore okuri for number") {
                    session.handle(.Char(kana: "1", roman: "", shift: true))
                    session.handle(.Char(kana: "2", roman: "", shift: true))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("12"))
                }
            }
            describe("alphabet input") {
                it("insert text") {
                    session.handle(.Char(kana: "a", roman: "", shift: false))
                    session.handle(.Char(kana: "b", roman: "", shift: false))
                    session.handle(.Char(kana: "c", roman: "", shift: false))
                    expect(self.insertedText).to(equal("abc"))
                }
                it("convert kanji") {
                    session.handle(.Char(kana: "a", roman: "", shift: true))
                    session.handle(.Char(kana: "b", roman: "", shift: false))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("ab"))
                }
                it("ignore okuri for alphabet") {
                    session.handle(.Char(kana: "a", roman: "", shift: true))
                    session.handle(.Char(kana: "b", roman: "", shift: true))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("ab"))
                }
                it("toggle upper/lower") {
                    session.handle(.Char(kana: "a", roman: "", shift: false))
                    session.handle(.Char(kana: "b", roman: "", shift: false))
                    session.handle(.ToggleUpperLower(beforeText: "ab"))
                    expect(self.insertedText).to(equal("abB"))
                }
            }
            describe("「っ」送り仮名変換") {
                it("can convert 「はいった」") {
                    session.handle(.Char(kana: "は", roman: "ta", shift: true))
                    session.handle(.Char(kana: "い", roman: "i", shift: false))
                    session.handle(.Char(kana: "つ", roman: "tu", shift: false))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Char(kana: "た", roman: "ta", shift: true))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("入った"))
                }

                it("can convert 「ひっぱる」"){
                    session.handle(.Char(kana: "ひ", roman: "ta", shift: true))
                    session.handle(.Char(kana: "つ", roman: "tu", shift: false))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Char(kana: "は", roman: "ha", shift: true))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("引っぱ"))
                }

                it("can convert 「ばっする」"){
                    session.handle(.Char(kana: "は", roman: "ta", shift: true))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Char(kana: "つ", roman: "tu", shift: false))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Char(kana: "す", roman: "su", shift: true))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("罰す"))
                }
            }
            describe("dictionary") {
                it("can register dakuten kana") {
                    session.handle(.Char(kana: "か", roman: "ka", shift: true))
                    session.handle(.Char(kana: "か", roman: "ka", shift: false))
                    session.handle(.Char(kana: "か", roman: "ka", shift: false))
                    session.handle(.Space)
                    session.handle(.Char(kana: "か", roman: "ka", shift: false))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("が"))
                }
            }
        }
    }
}