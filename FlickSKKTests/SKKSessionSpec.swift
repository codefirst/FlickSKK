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
    func composeText(text : String) {}
    func showCandidates(candidates : [String]?) {}
    
    // stub variable
    var insertedText = ""
    
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
                it("convert kanji with dakuten okuri") {
                    session.handle(.Char(kana: "か", roman: "ka", shift: true))
                    session.handle(.Char(kana: "ん", roman: "nn", shift: false))
                    session.handle(.Char(kana: "し", roman: "si", shift: true))
                    session.handle(.ToggleDakuten(beforeText: ""))
                    session.handle(.Enter)
                    expect(self.insertedText).to(equal("感じ"))                    
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
        }
    }
}