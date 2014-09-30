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
        return s.fromHankakuKanaToKatakana().fromKatakanaToHirakana()
    }
}