import Quick
import Nimble

class SKKNUmberPreprocessorSpec : QuickSpec {
    override func spec() {
        
        describe("preProcess") {
            it("数字を#に置き換える") {
                let target = SKKNumberPreprocessor(value: "15や")
                expect(target.preProcess()).to(equal("#や"))
            }
            it("64ビットでも処理できる") {
                let target = SKKNumberPreprocessor(value: "1000000000000や")
                expect(target.preProcess()).to(equal("#や"))
            }
        }

        describe("postProcess") {
            it("#nの置換") {
                let target = SKKNumberPreprocessor(value: "15や")
                target.preProcess()
                expect(target.postProcess("#0夜")).to(equal("15夜"))
                expect(target.postProcess("#1夜")).to(equal("１５夜"))
                expect(target.postProcess("#2夜")).to(equal("一五夜"))
                expect(target.postProcess("#3夜")).to(equal("十五夜"))
            }
            it("64ビットでも処理できる") {
                let target = SKKNumberPreprocessor(value: "1000000000000や")
                target.preProcess()
                expect(target.postProcess("#3夜")).to(equal("一兆夜"))
            }
        }
    }
}