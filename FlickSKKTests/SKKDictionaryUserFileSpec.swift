//
//  SKKDictionarySpec.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/11.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Quick
import Nimble

class SKKDictionaryUserFileSpec : QuickSpec {
    override func spec() {
        let path = NSHomeDirectory().stringByAppendingPathComponent("Library/skk-test.jisyo")
        let dict = SKKUserDictionaryFile(path: path)
        describe("SKK dictionary") {
            it("can find register entry") {
                dict.register("まじ", okuri: .None, kanji: "本気")
                let xs = dict.find("まじ", okuri: .None)
                expect(xs).to(contain("本気"))
            }
            it("can serialize entries") {
                dict.register("まじ", okuri: .None, kanji: "本気")
                dict.serialize()

                let dict2 = SKKUserDictionaryFile(path: path)
                let xs = dict2.find("まじ", okuri: .None)
                expect(xs).to(contain("本気"))
            }
        }
    }
}