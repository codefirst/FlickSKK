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
        describe("Character") {
            context("ひらかな to romain") {
                it("convert あ") {
                    let result = ("あ" as Character).toRoman()
                    expect(result).to(equal("a"))
                }
                it("convert が") {
                    let result = ("が" as Character).toRoman()
                    expect(result).to(equal("ga"))
                }
            }
            context("カタカナ to romain") {
                it("convert ア") {
                    let result = ("ア" as Character).toRoman()
                    expect(result).to(equal("a"))
                }
                it("convert ガ") {
                    let result = ("ガ" as Character).toRoman()
                    expect(result).to(equal("ga"))
                }
            }
            context("半角カナ to romain") {
                it("convert ｱ") {
                    let result = ("ｱ" as Character).toRoman()
                    expect(result).to(equal("a"))
                }
                it("convert ｶﾞ") {
                    let result = ("ｶﾞ" as Character).toRoman()
                    expect(result).to(equal("ga"))
                }
            }
        }
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
            context("ひらがな to ﾊﾝｶｸｶﾅ") {
                it("convert あ行") {
                    let result = "あいうえお".conv(.Hirakana, to: .HankakuKana)
                    expect(result).to(equal("ｱｲｳｴｵ"))
                }
                it("convert が行") {
                    let result = "がぎぐげご".conv(.Hirakana, to: .HankakuKana)
                    expect(result).to(equal("ｶﾞｷﾞｸﾞｹﾞｺﾞ"))
                }
                it("convert ゃゅょｰ") {
                    let result = "ゃゅょー".conv(.Hirakana, to: .HankakuKana)
                    expect(result).to(equal("ｬｭｮｰ"))
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
