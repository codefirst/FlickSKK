//
//  SKKDictionaryUserFile.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/17.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class SKKUserDictionaryFile  : SKKDictionaryFile {
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
        if old?.rangeOfString("/\(kanji)") == .None {
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