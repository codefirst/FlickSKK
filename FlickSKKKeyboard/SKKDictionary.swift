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
    init(path : String){
        self.path = path
        let now = NSDate()

        IOUtil.each(path, { line -> Void in
            let s = line as NSString
            // skip comment
            if(s.hasPrefix(";")) { return }

            switch self.parse(s) {
            case .Some(let x,let y):
                self.dictionary[x] = y
            case .None:
                ()
            }
        })
        NSLog("loaded (%f)\n", NSDate().timeIntervalSinceDate(now))
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        let entry : String? = self.dictionary[normal + (okuri ?? "")] as String?
        switch entry {
        case .Some(let xs):
            let ys : [String] = xs.pathComponents
            if ys.count <= 2 {
                return []
            } else {
                return Array(ys[1...ys.count-2])
            }
        case .None:
            return []
        }
    }

    private func parse(line : NSString) -> (String, String)? {
        let range = line.rangeOfString(" ")
        if range.location == NSNotFound {
            return .None
        } else {
            let kana  : NSString = line.substringToIndex(range.location)
            let kanji : NSString = line.substringFromIndex(range.location + 1)
            return (kana as String, kanji as String)
        }
    }

    func register(normal : String, okuri: String?, kanji: String) {
        if(kanji.isEmpty) { return }
        let old : String? = self.dictionary[normal + (okuri ?? "")] as String?
        self.dictionary[normal + (okuri ?? "")] =  "/" + kanji + "/" + (old ?? "")
    }

    func serialize() {
        let file = NSFileHandle(forWritingAtPath: self.path)
        for (k,v) in self.dictionary {
            let kana = k as String
            let kanji = v as String
            if !kana.isEmpty {
                let line  : NSString = (kana + " " + kanji + "\n") as NSString
                let data = NSData(bytes: line.UTF8String,
                                  length: line.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                file.writeData(data)
            }
        }
        file.closeFile()
    }
}

class SKKDictionary : NSObject {
    private var initialized = false

    var dictionaries : [ SKKDictionaryFile ] = []
    var userDict : SKKDictionaryFile?
    
    dynamic var isWaitingForLoad : Bool = false
    class func isWaitingForLoadKVOKey() -> String { return "isWaitingForLoad" }
    
    init(userDict: String, dicts : [String]){
        super.init()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.userDict = SKKDictionaryFile(path: userDict)
            self.dictionaries = [ self.userDict! ] + dicts.map({ x -> SKKDictionaryFile in
                SKKDictionaryFile(path: x)})
            self.initialized = true
        })
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        self.waitForLoading()
        
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
            self.userDict?.serialize()
            ()
        })
    }

    func waitForLoading() {
        if initialized { return }
        
        self.isWaitingForLoad = true
        while !self.initialized {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
        }
        self.isWaitingForLoad = false
    }
}
