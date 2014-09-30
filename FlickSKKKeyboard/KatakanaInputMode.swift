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
        return s.fromKatakanaToHirakana()
    }
}