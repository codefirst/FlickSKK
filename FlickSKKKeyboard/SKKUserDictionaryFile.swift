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
    class func defaultUserDictionaryPath() -> String {
        return AppGroup.pathForResource("Library/skk.jisyo") ?? NSHomeDirectory().stringByAppendingPathComponent("Library/skk.jisyo")
    }
    class func defaultUserDictionary() -> SKKUserDictionaryFile {
        return SKKUserDictionaryFile(path: self.defaultUserDictionaryPath())
    }

    // REMARK: Swift dictionary is too slow. So, we need use NSMutableDictionary.
    // [String:String]相当の実装になってる
    var okuriAri  = NSMutableDictionary()
    var okuriNasi = NSMutableDictionary()
    private let path : String

    init(path : String){
        self.path = path

        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes:nil)
        }

        // TODO: 変なデータが来たら、空で初期化する
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
        let entry : String? = dictFor(okuri)[normal + (okuri ?? "")] as String?
        return entry.map(split) ?? []
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
        let dict : NSMutableDictionary = dictFor(okuri)
        let old : String? = dict[normal + (okuri ?? "")] as String?
        if old?.rangeOfString("/\(kanji)") == .None {
            dict[normal + (okuri ?? "")] =  "/" + kanji + "/" + (old ?? "")
        }
    }

    func serialize() {
        if let file = NSFileHandle(forWritingAtPath: self.path) {
            // 前回の辞書の内容がのこっているので、いったんファイルの内容を全部消す
            file.truncateFileAtOffset(0)
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

    private func split(x : String) -> [String] {
        let xs = x.pathComponents
        if xs.count <= 2 {
            return []
        } else {
            return Array(xs[1...xs.count-2])
        }
    }

    func entries() -> [SKKDictionaryEntry] {
        var xs : [SKKDictionaryEntry] = []

        for (k, v) in okuriNasi {
            for kanji in split(v as String) {
                xs.append(.SKKDictionaryEntry(kanji: kanji, kana: k as String, okuri: .None))
            }
        }

        for (k, v) in okuriAri {
            let kana = (k as String).butLast()
            let okuri = (k as String).last()
            for kanji in split(v as String) {
                xs.append(.SKKDictionaryEntry(kanji: kanji, kana: kana, okuri: okuri))
            }
        }

        sort(&xs)
        return xs
    }

    func unregister(entry : SKKDictionaryEntry) {
        switch entry {
        case .SKKDictionaryEntry(kanji: let kanji, kana: let kana, okuri: let okuri):
            let words = self.find(kana, okuri: okuri).filter({ word in
                word != kanji
            })
            if words.isEmpty {
                dictFor(okuri).removeObjectForKey(kana + (okuri ?? ""))
            } else {
                // ["foo", "bar"] => "/foo/bar/"
                dictFor(okuri)[kana + (okuri ?? "")] = words.reduce("", {(x,y) in x + "/" + y }) + "/"
            }
            self.serialize()
        }
    }

    private func dictFor(okuri: String?) -> NSMutableDictionary {
        if okuri == .None {
            return self.okuriNasi
        } else {
            return self.okuriAri
        }
    }
}
