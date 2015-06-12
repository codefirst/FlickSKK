// 非同期に辞書のロードを行なう
class AsyncLoader {
    var initialized = false

    // 辞書をロードする
    func load(closure: () -> ()) {
       async {
            closure()
            self.initialized = true
        }
    }

    // ロード完了をまつ
    func wait() {
        while !self.initialized {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
        }
    }
}
