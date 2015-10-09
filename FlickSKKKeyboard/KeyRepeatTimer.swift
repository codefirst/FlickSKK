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
    private let action : Void -> Void
    private let delayInterval : NSTimeInterval
    private let repeatInterval : NSTimeInterval
    private var timer : NSTimer?


    init(delayInterval : NSTimeInterval, repeatInterval : NSTimeInterval, action: Void -> Void) {
        self.delayInterval = delayInterval
        self.repeatInterval = repeatInterval
        self.action = action
    }

    func start() {
        self.action()
        cancel()
        self.timer = NSTimer(
            fireDate: NSDate(timeIntervalSinceNow: self.delayInterval),
            interval: self.repeatInterval,
            target: self,
            selector: Selector("repeat"),
            userInfo: nil,
            repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }

    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc private func `repeat`() {
        self.action()
    }
}
