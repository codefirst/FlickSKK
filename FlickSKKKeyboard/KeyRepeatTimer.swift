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
  private var delayTimer : NSTimer?
  private var repeatTimer : NSTimer?


  init(delayInterval : NSTimeInterval, repeatInterval : NSTimeInterval, action: Void -> Void) {
    self.delayInterval = delayInterval
    self.repeatInterval = repeatInterval
    self.action = action
  }

  func start() {
    self.action()

    self.delayTimer = NSTimer.scheduledTimerWithTimeInterval(
      self.delayInterval,
      target: self,
      selector: Selector("delay"),
      userInfo: nil,
      repeats: false)
  }

  func cancel() {
    self.delayTimer?.invalidate()
    self.repeatTimer?.invalidate()
    self.delayTimer = nil
    self.repeatTimer = nil

  }

  func delay() {
    self.action()

    self.delayTimer = nil
    self.repeatTimer = NSTimer.scheduledTimerWithTimeInterval(
      self.repeatInterval,
      target: self,
      selector: Selector("repeat"),
      userInfo: nil,
      repeats: true)
  }

   func repeat() {
    self.action()
  }
}
