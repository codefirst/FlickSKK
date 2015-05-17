import Quick
import Nimble

class EntryParserSpec : QuickSpec {
    override func spec() {

        describe("words") {
            it("/で分割する") {
                let words = EntryParser(entry: "あお /青/蒼/").words()
                expect(words).to(contain("青", "蒼"))
            }
            it("エスケープを解除する") {
                let words = EntryParser(entry: "あお /[2f]/").words()
                expect(words).to(contain("/"))
            }
            it("アノテーションの除去") {
                let words = EntryParser(entry: "あーがい /アーガイ;魚(ヒブダイ)/").words()
                expect(words).to(contain("アーガイ"))
            }
        }
    }
}
