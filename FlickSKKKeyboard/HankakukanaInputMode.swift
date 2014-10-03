//
//  HankakukanaInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/01.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
class HankakukanaInputMode : InputModeBase {
    override func normalizeForDict(s: String) -> String {
        return s.conv(.HankakuKana, to: .Hirakana)
    }

    override func conv(text: String, mode: SKKInputMode) -> String {
        switch mode {
        case .Hirakana:
            return text.conv(.HankakuKana, to: .Hirakana)
        case .Katakana:
            return text.conv(.HankakuKana, to: .Katakana)
        case .HankakuKana:
            return text
        }
    }
}