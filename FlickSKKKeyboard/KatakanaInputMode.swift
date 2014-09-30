//
//  KatakanaInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/30.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class KatakanaInputMode : InputModeBase {
    override func findDict(text: String, okuri: (String, String)?) -> [String] {
        switch okuri {
        case .Some((let kana, let roman)):
            let okuri = roman.substringToIndex(advance(roman.startIndex, 1))
            let xs    = dict.find(text.toHirakana(), okuri: okuri)
            return xs.map({ (x : String)  ->  String in
                return x + kana
            })
        case .None:
            return dict.find(text.toHirakana(), okuri: .None)
        }
    }
}