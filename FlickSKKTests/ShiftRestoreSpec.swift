import Quick
import Nimble

class ShiftRestoreSpec : QuickSpec {

    override func spec() {
        var shiftRestore : ShiftRestore!

        beforeEach {
            shiftRestore = ShiftRestore()
        }

        context("直前がシフト入力なし") {
            describe("シフトキー入力なし") {
                beforeEach {
                    shiftRestore.handleKey(false, composeMode: .DirectInput)
                }
                it("シフトキー無効になる") {
                    expect(shiftRestore.shiftEnabled).to(beFalsy())
                }
            }

            describe("シフトキー入力あり") {
                beforeEach {
                    shiftRestore.handleKey(true, composeMode: .DirectInput)
                }
                it("シフトキー無効になる") {
                    expect(shiftRestore.shiftEnabled).to(beFalsy())
                }
            }

            describe("Backspace入力") {
                beforeEach {
                    shiftRestore.handleBackSpace(.DirectInput)
                }
                it("シフトキーが無効になる") {
                    expect(shiftRestore.shiftEnabled).to(beFalsy())
                }
            }
        }

        context("直前がシフト入力あり") {
            beforeEach {
                shiftRestore.handleKey(true, composeMode: .DirectInput)
            }

            describe("シフトキー入力なし") {
                beforeEach {
                    shiftRestore.handleKey(false, composeMode: .DirectInput)
                }
                it("シフトキー無効になる") {
                    expect(shiftRestore.shiftEnabled).to(beFalsy())
                }
            }

            describe("シフトキー入力あり") {
                beforeEach {
                    shiftRestore.handleKey(true, composeMode: .DirectInput)
                }
                it("シフトキーが無効になる") {
                    expect(shiftRestore.shiftEnabled).to(beFalsy())
                }
            }

            describe("Backspace入力") {
                describe("元の状態に戻る") {
                    beforeEach {
                        shiftRestore.handleBackSpace(.DirectInput)
                    }
                    it("シフトキーが有効になる") {
                        expect(shiftRestore.shiftEnabled).to(beTruthy())
                    }
                }

                describe("元の状態に戻らない") {
                    // 例: [↑][あ] -> [BackSpace]すると"▽"になり元の状態にもどらない
                    // この場合はシフトを復元してほしくない。
                    beforeEach {
                        shiftRestore.handleBackSpace(.KanaCompose(kana : "", candidates: []))
                    }
                    it("シフトキーが無効になる") {
                        expect(shiftRestore.shiftEnabled).to(beFalsy())
                    }
                }
            }
        }
    }
}