//
//  SKKKey.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

enum KeyEvent {
    case Char(kana : String, roman : String)
    case Space
    case Enter
    case Backspace
    case SelectCandidate(index: Int)
    case InputModeChange(inputMode : SKKInputMode)
    case ToggleDakuten
}
