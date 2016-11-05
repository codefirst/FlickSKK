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
    fileprivate let url : URL

    init(url : URL){
        self.url = url
        // TODO: 変なデータが来たら、空で初期化する
        let now = Date()
        var isOkuriAri = true
        if let path = url.path {
            IOUtil.each(path, with: { line -> Void in
                let s = line as NSString
                // toggle
                if s.hasPrefix(";; okuri-nasi entries.") {
                    isOkuriAri = false
                }
                // skip comment
                if(s.hasPrefix(";")) { return }

                switch self.parse(s) {
                case .some(let x,let y):
                    if isOkuriAri {
                        self.okuriAri[x] = y
                    } else {
                        self.okuriNasi[x] = y
                    }
                case .none:
                    break
                }
            })
        }
        NSLog("loaded (%f) (%d + %d entries from %@)\n", Date().timeIntervalSince(now), okuriAri.count, okuriNasi.count, url)
    }

    func entries() -> [SKKDictionaryEntry] {
        var xs : [SKKDictionaryEntry] = []

        for (k, v) in okuriNasi {
            for kanji in EntryParser(entry: v as! String).words() {
                xs.append(.skkDictionaryEntry(kanji: kanji, kana: k as! String, okuri: .none))
            }
        }

        for (k, v) in okuriAri {
            let kana = (k as! String).butLast()
            let okuri = (k as! String).last()
            for kanji in EntryParser(entry: v as! String).words() {
                xs.append(.skkDictionaryEntry(kanji: kanji, kana: kana, okuri: okuri))
            }
        }

        xs.sort()
        return xs
    }

    func find(_ normal : String, okuri : String?) -> [ String ] {
        if let entry = dictFor(okuri)[normal + (okuri ?? "")] as! String? {
            let parser = EntryParser(entry: entry)
            return parser.words()
        } else {
            return []
        }
    }

    func findWith(_ prefix: String) -> [(kana: String, kanji: String)] {
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

    func register(_ normal : String, okuri: String?, kanji: String) {
        if(kanji.isEmpty) { return }
        let dict : NSMutableDictionary = dictFor(okuri)
        let entry : String? = dict[normal + (okuri ?? "")] as! String?
        let parser = EntryParser(entry: entry ?? "")
        dict[normal + (okuri ?? "")] =  parser.append(kanji)
    }

    func serialize() {
        if let file = LocalFile(url: self.url) {
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

    func unregister(_ entry : SKKDictionaryEntry) {
        switch entry {
        case .skkDictionaryEntry(kanji: let kanji, kana: let kana, okuri: let okuri):
            let key = kana + (okuri ?? "")
            if let entry = dictFor(okuri)[key] as! String? {
                let parser = EntryParser(entry: entry)
                if let x = parser.remove(kanji) {
                    dictFor(okuri)[key] = x
                } else {
                    dictFor(okuri).removeObject(forKey: key)
                }
                self.serialize()
            }
        }
    }

    fileprivate func parse(_ line : NSString) -> (String, String)? {
        let range = line.range(of: " ")
        if range.location == NSNotFound {
            return .none
        } else {
            let kana : NSString = line.substring(to: range.location) as NSString
            let kanji : NSString = line.substring(from: range.location + 1) as NSString
            return (kana as String, kanji as String)
        }
    }

    fileprivate func dictFor(_ okuri: String?) -> NSMutableDictionary {
        if okuri == .none {
            return self.okuriNasi
        } else {
            return self.okuriAri
        }
    }
}
