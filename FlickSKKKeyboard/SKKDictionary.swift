//
//  SKKDictionary.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

protocol SKKDictionaryFile {
    func find(normal : String, okuri : String?) -> [ String ]
}

class SKKDictionaryUserFile  : SKKDictionaryFile {
    var dictionary : NSMutableDictionary = NSMutableDictionary()
    let path : String
    
    init(path : String){
        self.path = path

        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes:nil)
        }

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
            let kana : NSString = line.substringToIndex(range.location)
            let kanji : NSString = line.substringFromIndex(range.location + 1)
            return (kana as String, kanji as String)
        }
    }
    
    func register(normal : String, okuri: String?, kanji: String) {
        if(kanji.isEmpty) { return }
        let old : String? = self.dictionary[normal + (okuri ?? "")] as String?
        if old?.rangeOfString("/\(kanji)") != .None {
            self.dictionary[normal + (okuri ?? "")] =  "/" + kanji + "/" + (old ?? "")
        }
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

class SKKDictionaryLocalFile : SKKDictionaryFile {
    var isOkuriAri = true
    var okuriAri : NSMutableArray = NSMutableArray()
    var okuriNashi : NSMutableArray = NSMutableArray()
    let path : String
    init(path : String){
        self.path = path
        let now = NSDate()

        IOUtil.each(path, { line -> Void in
            let s = line as NSString
            // toggle
            if s.hasPrefix(";; okuri-nasi entries.") {
                self.isOkuriAri = false
            }
            // skip comment
            if s.hasPrefix(";") { return }

            if self.isOkuriAri {
                self.okuriAri.addObject(line)
            } else {
                self.okuriNashi.addObject(line)
            }
        })
        NSLog("loaded (%f)\n", NSDate().timeIntervalSinceDate(now))
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        switch okuri {
        case .None:
            let str = binarySearch(normal + " ",
                            xs: self.okuriNashi,
                            begin: 0, end: self.okuriNashi.count,
                            compare: NSComparisonResult.OrderedAscending) ?? ""
            return parse(str)
        case .Some(let okuri):
            let str = binarySearch(normal + okuri + " ",
                xs: self.okuriAri,
                begin: 0, end: self.okuriAri.count,
                compare: NSComparisonResult.OrderedDescending) ?? ""
            return parse(str)
        }
    }

    private func binarySearch(target : NSString, xs : NSMutableArray, begin : Int, end : Int, compare : NSComparisonResult) -> String? {
        if begin == end { return .None }
        if begin + 1 == end { return .None }

        let mid = (end - begin) / 2 + begin;
        let x  = xs[mid] as NSString
        if x.hasPrefix(target) {
            return x
        } else {
            if target.compare(x) == compare {
                return binarySearch(target, xs: xs, begin: begin, end: mid, compare : compare)
            } else {
                return binarySearch(target, xs: xs, begin: mid, end: end, compare : compare)
            }
        }
    }

    private func parse(line : NSString) -> [String] {
        let range = line.rangeOfString(" ")
        if range.location == NSNotFound {
            return []
        } else {
            let kanji : NSString = line.substringFromIndex(range.location + 1)
            let ys : [String] = (kanji as String).pathComponents
            if ys.count <= 2 {
                return []
            } else {
                return Array(ys[1...ys.count-2])
            }
        }
    }

}

class SKKDictionary : NSObject {
    private var initialized = false

    var dictionaries : [ SKKDictionaryFile ] = []
    var userDict : SKKDictionaryUserFile?
    
    dynamic var isWaitingForLoad : Bool = false
    class func isWaitingForLoadKVOKey() -> String { return "isWaitingForLoad" }
    
    init(userDict: String, dicts : [String]){
        super.init()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.userDict = SKKDictionaryUserFile(path: userDict)
            self.dictionaries = [ self.userDict! ] + dicts.map({ x -> SKKDictionaryFile in
                SKKDictionaryLocalFile(path: x)})
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
