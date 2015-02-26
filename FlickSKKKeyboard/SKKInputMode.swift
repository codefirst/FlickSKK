
//
//  SKKInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/30.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
enum SKKInputMode {
    case Hirakana
    case Katakana
    case HankakuKana

    func kanaType() -> KanaType {
        switch self {
        case .Hirakana:
            return .Hirakana
        case .Katakana:
            return .Katakana
        case .HankakuKana:
            return .HankakuKana
        }
    }
}
