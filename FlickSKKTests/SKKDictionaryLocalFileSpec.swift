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
        let bundle = Bundle(for: self.classForCoder)
        let jisyo = bundle.url(forResource: "skk", withExtension: "jisyo")
        let dict = SKKLocalDictionaryFile(url: jisyo!)
        describe("okuri-nasi") {
            it("can find at first entry") {
                let xs = dict.find("あいかた", okuri: .none)
                expect(xs).to(contain("相方"))
                expect(xs).to(contain("合方"))
            }
            it("can find at last entry") {
                let xs = dict.find("わりもどし", okuri: .none)
                expect(xs).to(contain("割戻し"))
                expect(xs).to(contain("割り戻し"))
            }
            it("can find one word entry") {
                let xs = dict.find("じ", okuri: .none)
                expect(xs).to(contain("字"))
            }
            it("can find number entry") {
                let xs = dict.find("1えん", okuri: .none)
                expect(xs).to(contain("一円"))
                expect(xs).to(contain("1円"))
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
