//
//  SKKDictionary.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class SKKDictionaryFile {
    var dictionary : NSMutableDictionary = NSMutableDictionary()
    let path : String
    let semaphore = dispatch_semaphore_create(0)
    init(path : String){
        self.path = path
        let content = NSString.stringWithContentsOfFile(path, encoding:NSUTF8StringEncoding, error: nil)
        content.enumerateLinesUsingBlock { (line, _) -> Void in
            // skip comment
            if(line.hasPrefix(";")) { return }

            switch self.parse(line) {
            case .Some(let x,let y):
                self.dictionary[x] = y
            case .None:
                ()
            }
        }
        NSLog("loaded %@\n", path)
        dispatch_semaphore_signal(self.semaphore)
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        switch self.dictionary[normal + (okuri ?? "")] {
        case .Some(let xs):
            return (xs as [ String ])
        case .None:
            return []
        }
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

    func register(normal : String, okuri: String?, kanji: String) {
        let old =
            find(normal, okuri: okuri)
        self.dictionary[normal + (okuri ?? "")] = [kanji] + old
        // TODO: flush into file
    }

    func serialie() {
        let file = NSFileHandle(forWritingAtPath: self.path)
        for (k,v) in self.dictionary {
            if !k.isEmpty {
                let xs : [ String ] = v as [String]
                let kanji : String = xs.reduce("/", combine: {(x : String, y : String) -> String in x + y + "/" })
                let kana  : String = k as String
                let line  : NSString = (kana + " " + kanji + "\n") as NSString
                let data = NSData(bytes: line.UTF8String,
                                  length: line.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                file.writeData(data)
            }

        }
        file.closeFile()
    }
}

class SKKDictionary {
    var dictionaries : [ SKKDictionaryFile ] = []
    var userDict : SKKDictionaryFile?
    init(userDict: String, dicts : [String]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.userDict = SKKDictionaryFile(path: userDict)
            self.dictionaries = [ self.userDict! ] + dicts.map({ x -> SKKDictionaryFile in
                SKKDictionaryFile(path: x)})
        })
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        let xs : [String] = self.dictionaries.map({(dict : SKKDictionaryFile) -> [String] in
            dict.find(normal, okuri: okuri)
        }).reduce([],
                  combine: {(x : [String], y : [String]) -> [String] in
            x + y
        })

        return xs
    }

    func register(normal : String, okuri: String?, kanji: String) {
        userDict?.register(normal, okuri: okuri, kanji: kanji)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.userDict?.serialie()
            ()
        })
    }
}
