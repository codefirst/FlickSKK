// バックスペースが押されたときに、元のシフトキー状態を復元するかどうかを判断する
// 基本的にバックスペースが押されたらシフトキーを復元するが、.KanaComposeモードに入った直後など
// もとの状態に戻らない場合は復元しない。
class ShiftRestore {
    private(set) var shiftEnabled = false
    private var prevShiftEnabled = false
    private var prevComposeMode : ComposeMode?

    init() {
    }

    // キーを処理する前に呼び出す
    func handleKey(shiftEnabled: Bool, composeMode: ComposeMode) {
        prevShiftEnabled = shiftEnabled
        prevComposeMode = composeMode
        self.shiftEnabled = false
    }

    // バックスペースキーを処理したあとに呼び出す
    func handleBackSpace(composeMode: ComposeMode) {
        if let prevComposeMode = self.prevComposeMode {
            self.shiftEnabled = self.prevShiftEnabled && (prevComposeMode == composeMode)
        } else {
            self.shiftEnabled = self.prevShiftEnabled
        }

        self.prevShiftEnabled = false
    }

}