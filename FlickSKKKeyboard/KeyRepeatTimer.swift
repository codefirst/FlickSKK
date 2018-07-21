//
//  KeyRepeatTimer.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 12/13/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

// KeyRepat用に定期的にコールバックしてくれるタイマ
//
//   1. 起動時にactionを呼び出す
//   2. delayInterval秒後にactionを呼びだす
//   3. repeatInterval秒毎にactionを呼び出す
class KeyRepeatTimer : NSObject {
    fileprivate let action : () -> Void
    fileprivate let delayInterval : TimeInterval
    fileprivate let repeatInterval : TimeInterval
    fileprivate var timer : Timer?


    init(delayInterval : TimeInterval, repeatInterval : TimeInterval, action: @escaping () -> Void) {
        self.delayInterval = delayInterval
        self.repeatInterval = repeatInterval
        self.action = action
    }

    func start() {
        self.action()
        cancel()
        self.timer = Timer(
            fireAt: Date(timeIntervalSinceNow: self.delayInterval),
            interval: self.repeatInterval,
            target: self,
            selector: #selector(KeyRepeatTimer.repeat),
            userInfo: nil,
            repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }

    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc fileprivate func `repeat`() {
        self.action()
    }
}
