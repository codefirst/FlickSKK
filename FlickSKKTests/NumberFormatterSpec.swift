//
//  NumberFormatterSpec.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 12/27/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

import Quick
import Nimble

class NumberFormatterSpec : QuickSpec {
    override func spec() {
        describe("stringfy") {
            it("stringfy int") {
                expect(NumberFormatter(value: 0).asAscii()).to(equal("0"))
                expect(NumberFormatter(value: 42).asAscii()).to(equal("42"))
            }

            it("stringfy as Full width") {
                expect(NumberFormatter(value: 0).asFullWidth()).to(equal("０"))
                expect(NumberFormatter(value: 42).asFullWidth()).to(equal("４２"))
            }

            it("stringfy as Japanese") {
                expect(NumberFormatter(value: 0).asJapanese()).to(equal("〇"))
                expect(NumberFormatter(value: 42).asJapanese()).to(equal("四二"))
            }


            it("stringfy as Kanji") {
                expect(NumberFormatter(value: 0).asKanji()).to(equal("零"))
                expect(NumberFormatter(value: 42).asKanji()).to(equal("四十二"))
                expect(NumberFormatter(value: 1024).asKanji()).to(equal("千二十四"))
                expect(NumberFormatter(value: 30000).asKanji()).to(equal("三万"))
                expect(NumberFormatter(value: 100000001).asKanji()).to(equal("一億一"))
            }
        }
    }
}