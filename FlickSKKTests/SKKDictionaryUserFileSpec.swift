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
        var dict: SKKUserDictionaryFile!

        describe("SKK dictionary") {
            beforeEach {
                NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                dict = SKKUserDictionaryFile(path: path)
            }

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
            it("return sorted entries") {
                dict.register("あああ", okuri: .None, kanji: "AAA")
                dict.register("あああ", okuri: .None, kanji: "BBB")
                dict.register("あああ", okuri: "い", kanji: "CCC")
                dict.register("いいい", okuri: .None, kanji: "DDD")

                let actual = dict.entries()
                expect(actual).to(equal([
                    .SKKDictionaryEntry(kanji: "AAA", kana: "あああ", okuri: .None),
                    .SKKDictionaryEntry(kanji: "BBB", kana: "あああ", okuri: .None),
                    .SKKDictionaryEntry(kanji: "CCC", kana: "あああ", okuri: "い"),
                    .SKKDictionaryEntry(kanji: "DDD", kana: "いいい", okuri: .None),
                    ]))
            }
            describe("unregister") {
                it("送りなしを全部消す") {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    dict.unregister(.SKKDictionaryEntry(kanji: "本気", kana: "まじ", okuri: .None))

                    let dict2 = SKKUserDictionaryFile(path: path)
                    let xs = dict2.find("まじ", okuri: .None)
                    expect(xs).notTo(contain("本気"))
                }

                it("送りありを1個消す") {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    dict.register("まじ", okuri: .None, kanji: "AAA")

                    dict.unregister(.SKKDictionaryEntry(kanji: "本気", kana: "まじ", okuri: .None))

                    let dict2 = SKKUserDictionaryFile(path: path)
                    let xs = dict2.find("まじ", okuri: .None)
                    expect(xs).to(contain("AAA"))
                }

                it("送りありを全部消す") {
                    dict.register("まじ", okuri: "a", kanji: "本気")
                    dict.unregister(.SKKDictionaryEntry(kanji: "本気", kana: "まじ", okuri: "a"))

                    let dict2 = SKKUserDictionaryFile(path: path)
                    let xs = dict2.find("まじ", okuri: "a")
                    expect(xs).notTo(contain("本気"))
                }

                it("送りありを1個消す") {
                    dict.register("まじ", okuri: "a", kanji: "本気")
                    dict.register("まじ", okuri: "a", kanji: "AAA")

                    dict.unregister(.SKKDictionaryEntry(kanji: "本気", kana: "まじ", okuri: "a"))

                    let dict2 = SKKUserDictionaryFile(path: path)
                    let xs = dict2.find("まじ", okuri: "a")
                    expect(xs).to(contain("AAA"))
                }
            }
        }
    }
}
