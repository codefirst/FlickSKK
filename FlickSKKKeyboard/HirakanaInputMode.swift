//
//  HankakuInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation


class HirakanaInputMode : InputModeBase {
    override func normalizeForDict(s: String) -> String {
        return s
    }

    override func conv(text: String, mode: SKKInputMode) -> String {
        switch mode {
        case .Hirakana:
            return text
        case .Katakana:
            return text.conv(.Hirakana, to: .Katakana)
        case .HankakuKana:
            return text.conv(.Hirakana, to: .HankakuKana)
        }
    }
}
