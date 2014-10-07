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
        let dict = SKKDictionary(userDict: jisyo!, dicts:[])
        dict.waitForLoading()
        
        beforeEach {
            session = SKKSession(delegate: self, dict: dict)
            self.insertedText = ""
        }
        
        context("hirakana mode") {
            it("insert text") {
                session.handle(.Char(kana: "あ", roman: "a", shift: false))
                session.handle(.Char(kana: "い", roman: "i", shift: false))
                session.handle(.Char(kana: "う", roman: "u", shift: false))
                expect(self.insertedText).to(equal("あいう"))
            }
            it("could convert kanji") {
                session.handle(.Char(kana: "や", roman: "ya", shift: true))
                session.handle(.Char(kana: "ま", roman: "ma", shift: false))
                session.handle(.Space)
                session.handle(.Enter)
                expect(self.insertedText).to(equal("山"))
            }
        }
    }
}