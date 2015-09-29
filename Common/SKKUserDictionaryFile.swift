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
    // REMARK: Swift dictionary is too slow. So, we need use NSMutableDictionary.
    // [String:String]相当の実装になってる
    var okuriAri  = NSMutableDictionary()
    var okuriNasi = NSMutableDictionary()
    private let path : String

    init(path : String){
        self.path = path

        // TODO: 変なデータが来たら、空で初期化する
        let now = NSDate()
        var isOkuriAri = true
        IOUtil.each(path, with: { line -> Void in
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
                break
            }
        })
        NSLog("loaded (%f) (%d + %d entries from %@)\n", NSDate().timeIntervalSinceDate(now), okuriAri.count, okuriNasi.count, path)
    }

    func entries() -> [SKKDictionaryEntry] {
        var xs : [SKKDictionaryEntry] = []

        for (k, v) in okuriNasi {
            for kanji in EntryParser(entry: v as! String).words() {
                xs.append(.SKKDictionaryEntry(kanji: kanji, kana: k as! String, okuri: .None))
            }
        }

        for (k, v) in okuriAri {
            let kana = (k as! String).butLast()
            let okuri = (k as! String).last()
            for kanji in EntryParser(entry: v as! String).words() {
                xs.append(.SKKDictionaryEntry(kanji: kanji, kana: kana, okuri: okuri))
            }
        }

        xs.sortInPlace()
        return xs
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        if let entry = dictFor(okuri)[normal + (okuri ?? "")] as! String? {
            let parser = EntryParser(entry: entry)
            return parser.words()
        } else {
            return []
        }
    }

    func findWith(prefix: String) -> [(kana: String, kanji: String)] {
        var xs : [(kana: String, kanji: String)] = []
        for (normal, entry) in self.okuriNasi {
            let n = normal as! String
            if n.hasPrefix(prefix) && n != prefix {
                let parser = EntryParser(entry: (entry as! String))
                for word in parser.words() {
                    xs.append(kana : n, kanji: word)
                }
            }
        }
        return xs
    }

    func register(normal : String, okuri: String?, kanji: String) {
        if(kanji.isEmpty) { return }
        let dict : NSMutableDictionary = dictFor(okuri)
        let entry : String? = dict[normal + (okuri ?? "")] as! String?
        let parser = EntryParser(entry: entry ?? "")
        dict[normal + (okuri ?? "")] =  parser.append(kanji)
    }

    func serialize() {
        if let file = LocalFile(path: self.path) {
            file.writeln(";; okuri-ari entries.")
            for (k,v) in self.okuriAri {
                let kana = k as! String
                let kanji = v as! String
                if !kana.isEmpty {
                    file.writeln(kana + " " + kanji)
                }
            }
            file.writeln(";; okuri-nasi entries.")
            for (k,v) in self.okuriNasi {
                let kana = k as! String
                let kanji = v as! String
                if !kana.isEmpty {
                    file.writeln(kana + " " + kanji)
                }
            }
            file.close()
        }
    }

    func unregister(entry : SKKDictionaryEntry) {
        switch entry {
        case .SKKDictionaryEntry(kanji: let kanji, kana: let kana, okuri: let okuri):
            let key = kana + (okuri ?? "")
            if let entry = dictFor(okuri)[key] as! String? {
                let parser = EntryParser(entry: entry)
                if let x = parser.remove(kanji) {
                    dictFor(okuri)[key] = x
                } else {
                    dictFor(okuri).removeObjectForKey(key)
                }
                self.serialize()
            }
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

    private func dictFor(okuri: String?) -> NSMutableDictionary {
        if okuri == .None {
            return self.okuriNasi
        } else {
            return self.okuriAri
        }
    }
}
