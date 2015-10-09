import Quick
import Nimble

class LoadLocalDicitonarySpec : QuickSpec {
    override func spec() {
        context("正常なファイル") {
            let url = DictionarySettings.defaultUserDictionaryURL()

            var dictionary : LoadLocalDictionary!
            beforeEach {
                if let file = LocalFile(url: url) {
                    defer { file.close() }
                    file.clear()

                    file.writeln(";; this is dictionary for spec")
                    file.writeln(";; okuri-ari entries.")
                    file.writeln("をs /惜/")
                    file.writeln("われらg /我等/")
                    file.writeln("")
                    file.writeln(";; okuri-nasi entries.")
                    file.writeln("! /！/感嘆符/")
                    file.writeln("!! /！！/")
                }
                dictionary = LoadLocalDictionary(url: url)
            }

            it("okuri ari") {
                expect(dictionary.okuriAri()).to(contain("をs /惜/"))
                expect(dictionary.okuriAri()).to(contain("われらg /我等/"))
                expect(dictionary.okuriAri()).notTo(contain(";; okuri-ari entries."))
                expect(dictionary.okuriAri()).notTo(contain(""))
            }

            it("okuri nasi") {
                expect(dictionary.okuriNasi()).to(contain("! /！/感嘆符/"))
                expect(dictionary.okuriNasi()).to(contain("!! /！！/"))
                expect(dictionary.okuriNasi()).notTo(contain(";; okuri-nasi entries."))
                expect(dictionary.okuriNasi()).notTo(contain(""))
            }
        }
    }
}