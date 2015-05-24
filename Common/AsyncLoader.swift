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

    // 非同期に処理を実行する
    func async(closure: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), closure)
    }
}
