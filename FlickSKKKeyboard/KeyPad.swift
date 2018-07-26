//
//  KeyPad.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/28.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
import UIKit
import NorthLayout
import Ikemen

class KeyPad : UIView {
    let keys: [KanaFlickKey]
    var keyButtons: [KeyButton]

    var tapped: ((KanaFlickKey, Int?) -> Void)?

    var metrics: [String:CGFloat] {
        return [:]
    }

    init(keys: [KanaFlickKey]) {
        self.keys = keys
        self.keyButtons = []
        super.init(frame: CGRect.zero)
        self.addKeypadKeys()
    }

    fileprivate func keyButton(_ key: KanaFlickKey) -> KeyButton {
        return KeyButton(key: key) ※ { (b:inout KeyButton) in
            weak var weakSelf = self
            b.tapped = { (key:KanaFlickKey, index:Int?) in
                weakSelf?.tapped?(key, index)
                return
            }
        }
    }

    func addKeypadKeys() {
        if (keys.count != 12) { print("fatal: cannot add keys not having 12 keys to keypad"); return; }


        let views: [String:UIView] = [
            "a": keyButton(keys[0]),
            "b": keyButton(keys[1]),
            "c": keyButton(keys[2]),
            "d": keyButton(keys[3]),
            "e": keyButton(keys[4]),
            "f": keyButton(keys[5]),
            "g": keyButton(keys[6]),
            "h": keyButton(keys[7]),
            "i": keyButton(keys[8]),
            "j": keyButton(keys[9]),
            "k": keyButton(keys[10]),
            "l": keyButton(keys[11]),
        ]

        let autolayoutInKeyPad = self.northLayoutFormat(metrics, views)
        autolayoutInKeyPad("H:|[a][b(==a)][c(==a)]|")
        autolayoutInKeyPad("H:|[d(==a)][e(==a)][f(==a)]|")
        autolayoutInKeyPad("H:|[g(==a)][h(==a)][i(==a)]|")
        autolayoutInKeyPad("H:|[j(==a)][k(==a)][l(==a)]|")
        autolayoutInKeyPad("V:|[a][d(==a)][g(==a)][j(==a)]|")
        autolayoutInKeyPad("V:|[b(==a)][e(==a)][h(==a)][k(==a)]|")
        autolayoutInKeyPad("V:|[c(==a)][f(==a)][i(==a)][l(==a)]|")

        self.keyButtons = (views as NSDictionary).allValues as! [KeyButton]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
