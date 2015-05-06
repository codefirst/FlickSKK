import Quick
import Nimble

class BinarySearchSpec : QuickSpec {
    override func spec() {

        let entries : NSArray = [
            "Alice",
            "Bob",
            "Charry",
            "David",
            "Eve"
        ]

        let target = BinarySearch(entries: entries, reverse: false)

        describe("search") {
            it("前方マッチ") {
                expect(target.call("Cha")).to(equal("Charry"))
            }
            it("見つからない場合はnil") {
                expect(target.call("Charrying")).to(beNil())
            }
        }

        describe("境界値") {
            it("1要素の場合") {
                let target = BinarySearch(entries: ["Alice"], reverse: false)
                expect(target.call("Ali")).to(equal("Alice"))
            }
        }
    }
}