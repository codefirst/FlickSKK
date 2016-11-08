//
//  SKKKey.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

enum SKKKeyEvent {
    case char(kana : String, shift : Bool)
    case space
    case enter
    case backspace
    case inputModeChange(inputMode : SKKInputMode)
    case toggleDakuten(beforeText : String)
    case toggleUpperLower(beforeText : String)
    case select(index : Int)
    case skipPartialCandidates
}

func ==(l : SKKKeyEvent, r : SKKKeyEvent) -> Bool {
    switch (l,r) {
    case (.char(kana: let kana1, shift: let shift1),
          .char(kana: let kana2, shift: let shift2)):
          return kana1 == kana2 && shift1 == shift2
    case (.space, .space):
        return true
    case (.enter, .enter):
        return true
    case (.backspace, .backspace):
        return true
    case (.inputModeChange(inputMode: let m1), .inputModeChange(inputMode: let m2)):
        return m1 == m2
    case (.toggleDakuten(_), .toggleDakuten(_)):
        return true
    case (.toggleUpperLower(_), .toggleUpperLower(_)):
        return true
    case (.select(index: let index1), .select(index: let index2)):
        return index1 == index2
    case (.skipPartialCandidates, .skipPartialCandidates):
        return true
    default:
        return false
    }
}
