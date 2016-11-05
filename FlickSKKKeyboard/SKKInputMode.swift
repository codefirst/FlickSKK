
//
//  SKKInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/30.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
enum SKKInputMode {
    case hirakana
    case katakana
    case hankakuKana

    func kanaType() -> KanaType {
        switch self {
        case .hirakana:
            return .hirakana
        case .katakana:
            return .katakana
        case .hankakuKana:
            return .hankakuKana
        }
    }
}
