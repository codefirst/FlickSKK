//
//  SKKKey.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

enum SKKKeyEvent {
    case Char(kana : String, shift : Bool)
    case Space
    case Enter
    case Backspace
    case InputModeChange(inputMode : SKKInputMode)
    case ToggleDakuten(beforeText : String)
    case ToggleUpperLower(beforeText : String)
    case Select(index : Int)
    case SkipPartialCandidates
}

func ==(l : SKKKeyEvent, r : SKKKeyEvent) -> Bool {
    switch (l,r) {
    case (.Char(kana: let kana1, shift: let shift1),
          .Char(kana: let kana2, shift: let shift2)):
          return kana1 == kana2 && shift1 == shift2
    case (.Space, .Space):
        return true
    case (.Enter, .Enter):
        return true
    case (.Backspace, .Backspace):
        return true
    case (.InputModeChange(inputMode: let m1), .InputModeChange(inputMode: let m2)):
        return m1 == m2
    case (.ToggleDakuten(_), .ToggleDakuten(_)):
        return true
    case (.ToggleUpperLower(_), .ToggleUpperLower(_)):
        return true
    case (.Select(index: let index1), .Select(index: let index2)):
        return index1 == index2
    case (.SkipPartialCandidates, .SkipPartialCandidates):
        return true
    default:
        return false
    }
}
