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
                try! NSFileManager.defaultManager().removeItemAtPath(path)
                dict = SKKUserDictionaryFile(path: path)
            }

            describe("findWith") {
                beforeEach {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                }

                it("前方一致で取得できる") {
                    let x = dict.findWith("ま")[0]
                    expect(x.kana).to(equal("まじ"))
                    expect(x.kanji).to(equal("本気"))
                }
                it("完全一致では取得できない") {
                    let xs = dict.findWith("まじ")
                    expect(xs).to(beEmpty())
                }
            }

            describe("register") {
                it("can find register entry") {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    let xs = dict.find("まじ", okuri: .None)
                    expect(xs).to(contain("本気"))
                }

                it("空文字が登録されない") {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    dict.register("まじ", okuri: .None, kanji: "AAA")
                    let xs = dict.find("まじ", okuri: .None)
                    expect(xs).toNot(contain(""))
                }

                it("特殊な文字も登録できる") {
                    dict.register("まじ", okuri: .None, kanji: "foo/bar;baz[xyzzy]")
                    let xs = dict.find("まじ", okuri: .None)
                    expect(xs).to(contain("foo/bar;baz[xyzzy]"))
                }

                it("同じ単語を複数回登録すると先頭に来る") {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    dict.register("まじ", okuri: .None, kanji: "AAA")
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    let xs = dict.find("まじ", okuri: .None)
                    expect(xs[0]).to(equal("本気"))
                }
            }

            describe("serialize") {
                it("can serialize entries") {
                    dict.register("まじ", okuri: .None, kanji: "本気")
                    dict.serialize()

                    let dict2 = SKKUserDictionaryFile(path: path)
                    let xs = dict2.find("まじ", okuri: .None)
                    expect(xs).to(contain("本気"))
                }

                it("特殊な文字も登録できる") {
                    dict.register("まじ", okuri: .None, kanji: "foo/bar;baz[xyzzy]")
                    dict.serialize()


                    let dict2 = SKKUserDictionaryFile(path: path)
                    let xs = dict2.find("まじ", okuri: .None)
                    expect(xs).to(contain("foo/bar;baz[xyzzy]"))
                }
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
