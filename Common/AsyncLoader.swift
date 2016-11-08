// 非同期に辞書のロードを行なう
class AsyncLoader {
    var initialized = false

    // 辞書をロードする
    func load(_ closure: @escaping () -> ()) {
       async {
            closure()
            self.initialized = true
        }
    }

    // ロード完了をまつ
    func wait() {
        while !self.initialized {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
}
