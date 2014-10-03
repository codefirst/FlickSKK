//
//  KatakanaInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/30.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class KatakanaInputMode : InputModeBase {
    override func normalizeForDict(s: String) -> String {
        return s.conv(.Katakana,to: .Hirakana)
    }

    override func conv(text: String, mode: SKKInputMode) -> String {
        switch mode {
        case .Hirakana:
            return text.conv(.Katakana, to: .Hirakana)
        case .Katakana:
            return text
        case .HankakuKana:
            return text.conv(.Katakana, to: .HankakuKana)
        }
    }
}