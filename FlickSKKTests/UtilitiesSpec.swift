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
        }
    }
}