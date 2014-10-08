//
//  UtilitiesSpec.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/06.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Quick
import Nimble

class UtilitiesSpec: QuickSpec {
    override func spec() {
        describe("String") {
            context("ひらがな to カタカナ") {
                it("convert あ行") {
                    let result = "あいうえお".conv(.Hirakana, to: .Katakana)
                    expect(result).to(equal("アイウエオ"))
                }
                it("convert 'ポップアップ'") {
                    let result = "ぽっぷあっぷ".conv(.Hirakana, to: .Katakana)
                    expect(result).to(equal("ポップアップ"))
                }
            }
            context("toggle upper case/lower case") {
                it("convert ABCZ") {
                    expect("A".toggleUpperLower()).to(equal("a"))
                    expect("H".toggleUpperLower()).to(equal("h"))
                    expect("Z".toggleUpperLower()).to(equal("z"))
                }
                it("convert abc") {
                    expect("a".toggleUpperLower()).to(equal("A"))
                    expect("h".toggleUpperLower()).to(equal("H"))
                    expect("z".toggleUpperLower()).to(equal("Z"))
                }
            }
        }
    }
}