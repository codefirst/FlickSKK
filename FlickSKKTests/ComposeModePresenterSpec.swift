import Quick
import Nimble

class ComposeModePresenterSpec : QuickSpec {

    override func spec() {
        let target = ComposeModePresenter()
        describe("toString") {
            it("direct input") {
                expect(target.toString(.DirectInput)).to(equal(""))
            }
            it("kana compose mode") {
                expect(target.toString(.KanaCompose(kana: "こんにちは"))).to(equal("▽こんにちは"))
            }
            it("kanji compose mode") {
                let m = ComposeMode.KanjiCompose(kana: "ほんき", okuri: .None, candidates: ["本気"], index: 0)
                expect(target.toString(m)).to(equal("▼本気"))
            }
            it("word regisetr mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.DirectInput])
                expect(target.toString(m)).to(equal("[登録:ほんき]あああ"))
            }
            it("word regisetr mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ろうたけ", okuri: "る", composeText: "あああ", composeMode: [.DirectInput])
                expect(target.toString(m)).to(equal("[登録:ろうたけ*る]あああ"))
            }
            it("word regisetr mode(kana compose)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あ", composeMode: [.KanaCompose(kana: "い")])
                expect(target.toString(m)).to(equal("[登録:ほんき]あ▽い"))
            }
        }

        describe("candidates") {
            it("direct input") {
                expect(target.candidates(.DirectInput)).to(beNil())
            }
            it("kana compose mode") {
                expect(target.candidates(.KanaCompose(kana: "こんにちは"))).to(beNil())
            }
            it("kanji compose mode") {
                let m = ComposeMode.KanjiCompose(kana: "ほんき", okuri: .None, candidates: ["foo", "bar"], index: 1)
                let (candidates, index) = target.candidates(m) ?? ([],0)
                expect(candidates).to(equal(["foo", "bar"]))
                expect(index).to(equal(1))

            }
            it("word regisetr mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.DirectInput])
                expect(target.candidates(m)).to(beNil())
            }
            it("word regisetr mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ろうたけ", okuri: "る", composeText: "あああ", composeMode: [.DirectInput])
                expect(target.toString(m)).to(equal("[登録:ろうたけ*る]あああ"))
            }
            it("word regisetr mode(kana compose)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あ", composeMode: [
                    .KanjiCompose(kana: "ほんき", okuri: .None, candidates: ["foo", "bar"], index: 1)
                ])
                let (candidates, index) = target.candidates(m) ?? ([],0)
                expect(candidates).to(equal(["foo", "bar"]))
                expect(index).to(equal(1))
            }
        }
    }
}
