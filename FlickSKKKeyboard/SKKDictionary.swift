//
//  SKKDictionary.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class SKKDictionary {
    var dictionary : [String:[String]] = [:]
    init(path : String){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let content = NSString.stringWithContentsOfFile(path, encoding:NSUTF8StringEncoding, error: nil)
            content.enumerateLinesUsingBlock { (line, _) -> Void in
                // skip comment
                if(line.hasPrefix(";")) { return }

                switch self.parse(line) {
                    case .Some(let x,let y):
                        // FIXME: TOO MUCH SLOW!!!
                        self.dictionary[x] = y
                    case .None:
                        ()
                }
            }
        })
    }

    func find(noraml : String, okuri : String?) -> [ String ] {
        return self.dictionary[noraml + (okuri ?? "")] ?? []
    }

    private func parse(line : String) -> (String, [String])? {
        switch line.rangeOfString(" ") {
        case .Some(let range):
            let kana  = line.substringToIndex(range.startIndex)
            let kanji = line.substringFromIndex(range.startIndex)
            let xs    = kanji.componentsSeparatedByString("/").filter({(x : String) -> Bool in
                return !x.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " ")).isEmpty
            })
            return (kana, xs)
        case .None:
            return .None
        }
    }
}
