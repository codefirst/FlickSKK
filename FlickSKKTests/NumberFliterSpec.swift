import Quick
import Nimble

class NumberFilterSpec : QuickSpec {

    func search(str : String) -> [String] {
        let binarySearch = BinarySearch(entries: [
            "#や /#0夜/#1夜/#2夜/#3夜/"
        ], reverse: false)

        return NumberFilter().call(str, binarySearch: binarySearch) {
            EntryParser(entry: $0).words()
        }
    }

    override func spec() {
        describe("検索できる") {
            it("数字を#に置き換える") {
                let target = self.search("15や")
                expect(target).notTo(beEmpty())
            }

            it("#nの置換") {
                let target = self.search("15や")
                expect(target).to(contain("15夜","１５夜", "一五夜", "十五夜"))
            }
        }
        describe("32ビット幅を越えた場合") {
            it("検索できる") {
                let target = self.search("1000000000000や")
                expect(target).notTo(beEmpty())
            }

            it("#nの置換") {
                let target = self.search("1000000000000や")
                expect(target).to(contain("一兆夜"))
            }
        }
    }
}
