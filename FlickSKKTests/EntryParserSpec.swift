import Quick
import Nimble

class EntryParserSpec : QuickSpec {
    override func spec() {

        describe("正常な形式") {
            it("/で分割する") {
                let entry = EntryParser(entry: "あお /青/蒼/")
                expect(entry.title()).to(equal("あお"))
                expect(entry.words()).to(contain("青", "蒼"))
            }
            it("エスケープを解除する") {
                let entry = EntryParser(entry: "あお /[2f]/")
                expect(entry.title()).to(equal("あお"))
                expect(entry.words()).to(contain("/"))
            }
            it("アノテーションの除去") {
                let entry = EntryParser(entry: "あーがい /アーガイ;魚(ヒブダイ)/")
                expect(entry.title()).to(equal("あーがい"))
                expect(entry.words()).to(contain("アーガイ"))
            }
        }

        describe("不正な形式") {
            it("見出し語がない") {
                let entry = EntryParser(entry: "foo")
                expect(entry.title()).to(beNil())
            }

            it("単語が/で囲まれていない") {
                let entry = EntryParser(entry: "foo bar")
                expect(entry.words()).to(beEmpty())
            }
        }

    }
}
