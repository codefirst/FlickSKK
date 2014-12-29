//
//  SKKDictionaryLocalFIle.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/17.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

/*
 * L辞書などの固定辞書。ソートされていることを前提に、二分探索などを行なう。
 */
class SKKLocalDictionaryFile : SKKDictionaryFile {
    private var okuriAri : NSMutableArray = NSMutableArray()
    private var okuriNasi : NSMutableArray = NSMutableArray()
    private let path : String
    init(path : String){
        self.path = path
        let now = NSDate()
        var isOkuriAri = true
        IOUtil.each(path, { line -> Void in
            let s = line as NSString
            // toggle
            if s.hasPrefix(";; okuri-nasi entries.") {
                isOkuriAri = false
            }
            // skip comment
            if s.hasPrefix(";") { return }

            if isOkuriAri {
                self.okuriAri.addObject(line)
            } else {
                self.okuriNasi.addObject(line)
            }
        })
        NSLog("loaded (%f)\n", NSDate().timeIntervalSinceDate(now))
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        switch okuri {
        case .None:
            return search(normal + " ",
                xs: self.okuriNasi,
                compare: NSComparisonResult.OrderedAscending)
        case .Some(let okuri):
            return search(normal + okuri + " ",
                xs: self.okuriAri,
                compare: NSComparisonResult.OrderedDescending)
        }
    }

    private func search(target : NSString, xs : NSMutableArray, compare : NSComparisonResult) -> [String] {
        let preprocessor = SKKNumberPreprocessor(value: target)

        let line = binarySearch(preprocessor.preProcess(),
            xs: xs,
            begin: 0,
            end: xs.count,
            compare: compare) ?? ""

        let entries = parse(line)

        return entries.map({ entry in
            return preprocessor.postProcess(entry) })
    }

    private func binarySearch(target : NSString, xs : NSMutableArray, begin : Int, end : Int, compare : NSComparisonResult) -> String? {
        if begin == end { return .None }
        if begin + 1 == end { return .None }

        let mid = (end - begin) / 2 + begin;
        let x  = xs[mid] as NSString
        if x.hasPrefix(target) {
            return x
        } else {
            if target.compare(x, options: .LiteralSearch) == compare {
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
