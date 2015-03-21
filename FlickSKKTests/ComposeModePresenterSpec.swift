import Quick
import Nimble

class ComposeModePresenterSpec : QuickSpec {

    override func spec() {
        let target = ComposeModePresenter()
        let candidates : [Candidate] = [ .Original(kanji: "本気"), .Abbrev(kanji: "マジ", kana: "まじ") ]
        describe("toString") {
            it("direct input") {
                expect(target.toString(.DirectInput)).to(equal(""))
            }
            it("kana compose mode") {
                expect(target.toString(.KanaCompose(kana: "こんにちは", candidates: candidates))).to(equal("▽こんにちは"))
            }
            it("kanji compose mode") {
                let m = ComposeMode.KanjiCompose(kana: "ほんき", okuri: .None, candidates: candidates, index: 0)
                expect(target.toString(m)).to(equal("▼本気"))
            }
            it("word register mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.DirectInput])
                expect(target.toString(m)).to(equal("[登録:ほんき]あああ"))
            }
            it("word register mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ろうたけ", okuri: "る", composeText: "あああ", composeMode: [.DirectInput])
                expect(target.toString(m)).to(equal("[登録:ろうたけ*る]あああ"))
            }
            it("word register mode(kana compose)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あ",
                    composeMode: [.KanaCompose(kana: "い", candidates: [])])
                expect(target.toString(m)).to(equal("[登録:ほんき]あ▽い"))
            }
        }

        describe("candidates") {
            it("direct input") {
                expect(target.candidates(.DirectInput)).to(beNil())
            }
            it("kana compose mode") {
                let c = target.candidates(.KanaCompose(kana: "こんにちは", candidates: candidates))
                expect(c?.candidates).to(equal(["本気", "#マジ"]))
                expect(c?.index).to(beNil())

            }
            it("kanji compose mode") {
                let m = ComposeMode.KanjiCompose(kana: "ほんき", okuri: .None, candidates: candidates, index: 1)
                let c = target.candidates(m)
                expect(c?.candidates).to(equal(["本気", "#マジ"]))
                expect(c?.index).to(equal(1))

            }
            it("word register mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.DirectInput])
                expect(target.candidates(m)).to(beNil())
            }
            it("word register mode(kana compose)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あ", composeMode: [
                    .KanjiCompose(kana: "ほんき", okuri: .None, candidates: candidates, index: 1)
                ])
                let (candidates, index) = target.candidates(m) ?? ([],0)
                expect(candidates).to(equal(["本気", "#マジ"]))
                expect(index).to(equal(1))
            }
        }


        describe("inStatusShowsCandidatesBySpace") {
            it("direct input") {
                expect(target.inStatusShowsCandidatesBySpace(.DirectInput)).to(beFalse())
            }
            it("kana compose mode") {
                let ret = target.inStatusShowsCandidatesBySpace(.KanaCompose(kana: "こんにちは", candidates: candidates))
                expect(ret).to(beTrue())
            }
            it("kanji compose mode") {
                let m = ComposeMode.KanjiCompose(kana: "ほんき", okuri: .None, candidates: candidates, index: 1)
                let ret = target.inStatusShowsCandidatesBySpace(m)
                expect(ret).to(beTrue())
            }
            it("word register mode(direct)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.DirectInput])
                let ret = target.inStatusShowsCandidatesBySpace(m)
                expect(ret).to(beFalse())
            }
            it("word register mode(kana compose)") {
                let m = ComposeMode.WordRegister(kana: "ほんき", okuri: nil, composeText: "あ", composeMode: [
                    .KanjiCompose(kana: "ほんき", okuri: .None, candidates: candidates, index: 1)
                    ])
                let ret = target.inStatusShowsCandidatesBySpace(m)
                expect(ret).to(beTrue())
            }
        }
    }
}
