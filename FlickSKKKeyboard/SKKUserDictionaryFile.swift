//
//  SKKDictionaryUserFile.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/17.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

/*
 * ユーザ辞書。並び順について仮定を持たない。
 */
class SKKUserDictionaryFile  : SKKDictionaryFile {
    class func defaultUserDictionaryPath() -> String { return AppGroup.pathForResource("Library/skk.jisyo") ?? NSHomeDirectory().stringByAppendingPathComponent("Library/skk.jisyo") }
    class func defaultUserDictionary() -> SKKUserDictionaryFile {
        return SKKUserDictionaryFile(path: self.defaultUserDictionaryPath())
    }
    
    // REMARK: Swift dictionary is too slow. So, we need use NSMutableDictionary.
    var okuriAri  = NSMutableDictionary()
    var okuriNasi = NSMutableDictionary()
    private let path : String
    
    init(path : String){
        self.path = path
        
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes:nil)
        }
        
        let now = NSDate()
        var isOkuriAri = true
        IOUtil.each(path, { line -> Void in
            let s = line as NSString
            // toggle
            if s.hasPrefix(";; okuri-nasi entries.") {
                isOkuriAri = false
            }
            // skip comment
            if(s.hasPrefix(";")) { return }

            switch self.parse(s) {
            case .Some(let x,let y):
                if isOkuriAri {
                    self.okuriAri[x] = y
                } else {
                    self.okuriNasi[x] = y
                }
            case .None:
                ()
            }
        })
        NSLog("loaded (%f) (%d + %d entries from %@)\n", NSDate().timeIntervalSinceDate(now), okuriAri.count, okuriNasi.count, path)
    }
    
    func find(normal : String, okuri : String?) -> [ String ] {
        var entry : String?
        if okuri == .None {
            entry = self.okuriNasi[normal] as String?
        } else {
            entry = self.okuriAri[normal + (okuri ?? "")] as String?
        }
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
        var dict : NSMutableDictionary!
        if okuri == .None {
            dict = self.okuriNasi
        } else {
            dict = self.okuriAri
        }
        let old : String? = dict[normal + (okuri ?? "")] as String?
        if old?.rangeOfString("/\(kanji)") == .None {
            dict[normal + (okuri ?? "")] =  "/" + kanji + "/" + (old ?? "")
        }
    }
    
    func serialize() {
        if let file = NSFileHandle(forWritingAtPath: self.path) {
            write(file, str: ";; okuri-ari entries.\n")
            for (k,v) in self.okuriAri {
                let kana = k as String
                let kanji = v as String
                if !kana.isEmpty {
                    write(file, str: kana + " " + kanji + "\n")
                }
            }
            write(file, str: ";; okuri-nasi entries.\n")
            for (k,v) in self.okuriNasi {
                let kana = k as String
                let kanji = v as String
                if !kana.isEmpty {
                    write(file, str: kana + " " + kanji + "\n")
                }
            }
            file.closeFile()
        }
    }

    private func write(handle : NSFileHandle, str : NSString) {
        let data = NSData(bytes: str.UTF8String,
                          length: str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        handle.writeData(data)
    }
}