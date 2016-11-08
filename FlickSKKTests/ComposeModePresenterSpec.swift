import Quick
import Nimble

class ComposeModePresenterSpec : QuickSpec {

    override func spec() {
        let target = ComposeModePresenter()
        let candidates : [Candidate] = [ .exact(kanji: "本気"), .partial(kanji: "マジ", kana: "まじ") ]
        describe("toString") {
            it("direct input") {
                expect(target.toString(.directInput)).to(equal(""))
            }
            it("kana compose mode") {
                expect(target.toString(.kanaCompose(kana: "こんにちは", candidates: candidates))).to(equal("▽こんにちは"))
            }
            it("kanji compose mode") {
                let m = ComposeMode.kanjiCompose(kana: "ほんき", okuri: .none, candidates: candidates, index: 0)
                expect(target.toString(m)).to(equal("▼ほんき"))
            }
            it("word register mode(direct)") {
                let m = ComposeMode.wordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.directInput])
                expect(target.toString(m)).to(equal("[登録:ほんき]あああ"))
            }
            it("word register mode(direct)") {
                let m = ComposeMode.wordRegister(kana: "ろうたけ", okuri: "る", composeText: "あああ", composeMode: [.directInput])
                expect(target.toString(m)).to(equal("[登録:ろうたけ*る]あああ"))
            }
            it("word register mode(kana compose)") {
                let m = ComposeMode.wordRegister(kana: "ほんき", okuri: nil, composeText: "あ",
                    composeMode: [.kanaCompose(kana: "い", candidates: [])])
                expect(target.toString(m)).to(equal("[登録:ほんき]あ▽い"))
            }
        }

        describe("candidates") {
            it("direct input") {
                expect(target.candidates(.directInput)).to(beNil())
            }
            it("kana compose mode") {
                let c = target.candidates(.kanaCompose(kana: "こんにちは", candidates: candidates))
                expect(c?.candidates).to(equal(candidates))
                expect(c?.index).to(beNil())

            }
            it("kanji compose mode") {
                let m = ComposeMode.kanjiCompose(kana: "ほんき", okuri: .none, candidates: candidates, index: 1)
                let c = target.candidates(m)
                expect(c?.candidates).to(equal(candidates))
                expect(c?.index).to(equal(1))

            }
            it("word register mode(direct)") {
                let m = ComposeMode.wordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.directInput])
                expect(target.candidates(m)).to(beNil())
            }
            it("word register mode(kana compose)") {
                let m = ComposeMode.wordRegister(kana: "ほんき", okuri: nil, composeText: "あ", composeMode: [
                    .kanjiCompose(kana: "ほんき", okuri: .none, candidates: candidates, index: 1)
                ])
                let (cs, index) = target.candidates(m) ?? ([],0)
                expect(cs).to(equal(candidates))
                expect(index).to(equal(1))
            }
        }


        describe("inStatusShowsCandidatesBySpace") {
            it("direct input") {
                expect(target.inStatusShowsCandidatesBySpace(.directInput)).to(beFalse())
            }
            it("kana compose mode") {
                let ret = target.inStatusShowsCandidatesBySpace(.kanaCompose(kana: "こんにちは", candidates: candidates))
                expect(ret).to(beTrue())
            }
            it("kanji compose mode") {
                let m = ComposeMode.kanjiCompose(kana: "ほんき", okuri: .none, candidates: candidates, index: 1)
                let ret = target.inStatusShowsCandidatesBySpace(m)
                expect(ret).to(beTrue())
            }
            it("word register mode(direct)") {
                let m = ComposeMode.wordRegister(kana: "ほんき", okuri: nil, composeText: "あああ", composeMode: [.directInput])
                let ret = target.inStatusShowsCandidatesBySpace(m)
                expect(ret).to(beFalse())
            }
            it("word register mode(kana compose)") {
                let m = ComposeMode.wordRegister(kana: "ほんき", okuri: nil, composeText: "あ", composeMode: [
                    .kanjiCompose(kana: "ほんき", okuri: .none, candidates: candidates, index: 1)
                    ])
                let ret = target.inStatusShowsCandidatesBySpace(m)
                expect(ret).to(beTrue())
            }
        }
    }
}
