//
//  SKKDictionarySpec.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/11.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Quick
import Nimble

class SKKDictionaryLocalFileSpec : QuickSpec {
    override func spec() {
        let jisyo = NSBundle.mainBundle().pathForResource("skk", ofType: "jisyo")
        let dict = SKKDictionaryLocalFile(path: jisyo!)
        describe("okuri-nasi") {
            it("can find at first entry") {
                let xs = dict.find("あいかた", okuri: .None)
                expect(xs).to(contain("相方"))
                expect(xs).to(contain("合方"))
            }
            it("can find at last entry") {
                let xs = dict.find("わりもどし", okuri: .None)
                expect(xs).to(contain("割戻し"))
                expect(xs).to(contain("割り戻し"))
            }
        }
        describe("okuri-ari") {
            it("can find first entry"){
                let xs = dict.find("わりもど", okuri: "s")
                expect(xs).to(contain("割り戻"))
                expect(xs).to(contain("割戻"))
            }
            it("can find last entry") {
                let xs = dict.find("あいう", okuri: "t")
                expect(xs).to(contain("相討"))
                expect(xs).to(contain("相打"))
            }
        }
    }
}