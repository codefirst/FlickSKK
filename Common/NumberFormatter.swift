//
//  NumberFormatter.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 12/27/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

class NumberFormatter {
    let value : Int64
    init(value : Int64) {
        self.value = value
    }

    func asAscii() -> String {
        return NSString(format: "%d", self.value) as String
    }

    func asFullWidth() -> String {
        return conv(asAscii(), from: "0123456789", to: "０１２３４５６７８９")
    }

    func asJapanese() -> String {
        return conv(asAscii(), from: "0123456789", to: "〇一二三四五六七八九")
    }

    func asKanji() -> String {
        if value == 0 {
            return "零"
        } else {
            return toKanji(value)
        }
    }

    fileprivate func conv(_ target : String, from : String, to : String) -> String {
        return implode(Array(target.characters).map( { c in
            tr(c, from: from, to: to) ?? c
        }))
    }


    fileprivate func toKanji_lt_10(_ n : Int) -> String? {
        // where n < 10
        if n == 0 {
            return .none
        } else if n == 1 {
            return ""
        } else {
            let xs = Array("__二三四五六七八九".characters)
            return String(xs[n])
        }
    }

    fileprivate func toKanjiDigit(_ n : Int64, at : Int64, name: String) -> String {
        let m : Int = Int((n / at) % 10)
        return toKanji_lt_10(m).map({ c in c + name }) ?? ""
    }

    fileprivate func toKanji_lt_10000(_ n : Int64) -> String? { // where n < 10_000
        if n == 0 {
            return .none
        } else if n == 1 {
            return "一"
        } else {
            let _1000 = toKanjiDigit(n, at: 1000, name: "千")
            let _100 = toKanjiDigit(n, at: 100, name: "百")
            let _10 = toKanjiDigit(n, at: 10, name: "十")
            let _1 = toKanjiDigit(n, at: 1, name: "")
            return _1000 + _100 + _10 + _1
        }
    }

    fileprivate func toKanjiDigits(_ n : Int64, at : Int64, name: String) -> String {
        return toKanji_lt_10000((n / at) % Int64(1_0000)).map({ c in c + name }) ?? ""
    }

    fileprivate func toKanji(_ n : Int64) -> String {
        let 兆 = toKanjiDigits(n, at: 1_0000_0000_0000, name: "兆")
        let 億 = toKanjiDigits(n, at: 1_0000_0000, name: "億")
        let 万 = toKanjiDigits(n, at: 1_0000, name: "万")
        let rest = toKanjiDigits(n, at: 1, name: "")

        return 兆 + 億 + 万 + rest
    }
}
