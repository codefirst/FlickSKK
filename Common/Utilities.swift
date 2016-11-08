//
//  Utilities.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/28.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
import UIKit


extension NSObject {
    func tap<T>(_ block:(T) -> Void) -> Self {
        block(self as! T)
        return self
    }
}

extension UIButton {
    func setBackgroundImage(color: UIColor, forState state: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        color.setFill()
        UIRectFillUsingBlendMode(CGRect(x: 0, y: 0, width: 1, height: 1), CGBlendMode.copy)
        self.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), for: state)
        UIGraphicsEndImageContext()
    }
}

// 非同期に処理を実行する
func async(_ closure: @escaping () -> ()) {
    DispatchQueue.global(qos: .default).async(execute: closure)
}

func dictionaryWithKeyValues<K,V>(_ pairs: [(K,V)]) -> [K:V] {
    var d: [K:V] = [:]
    for (k, v) in pairs {
        d[k] = v
    }
    return d
}

func toggle(_ s : String, table : [[String?]]) -> String? {
    for (i,t) in table.enumerated() {
        for (j, x) in t.enumerated() {
            if s == x {
                if let next = table[(i + 1) % table.count][j] ?? table[(i + 2) % table.count][j] {
                    return .some(next)
                }
            }
        }
    }
    return .none
}

func tr(_ c : Character, from : String, to : String) -> Character? {
    /*
     * REMARK:
     * - Stringのsubscriptionだと半角カナのカナと濁点が分離してしまう。
     * - Arrayに変換するとカナと濁点をセットにしたまま分割できる。
     * - String.IndexをIntに変換する方法がわからなかったので、NSStringのメソッドを利用している。
     */
    let r = (from as NSString).range(of: String(c))
    if r.location != NSNotFound {
        return Array(to.characters)[r.location]
    }
    return .none
}

// FIXME: more effective
func implode(_ xs : [Character]) -> String {
    var str = ""
    for x in xs {
        str += String(x)
    }
    return str
}

extension Character {
    func toRoman() -> String? {
        let table : [Character:String] = [
            "あ" : "a",
            "い" : "i",
            "う" : "u",
            "え" : "e",
            "お" : "o",
            "か" : "ka",
            "き" : "ki",
            "く" : "ku",
            "け" : "ke",
            "こ" : "ko",
            "さ" : "sa",
            "し" : "si",
            "す" : "su",
            "せ" : "se",
            "そ" : "so",
            "た" : "ta",
            "ち" : "ti",
            "つ" : "tu",
            "て" : "te",
            "と" : "to",
            "な" : "na",
            "に" : "ni",
            "ぬ" : "nu",
            "ね" : "ne",
            "の" : "no",
            "は" : "ha",
            "ひ" : "hi",
            "ふ" : "hu",
            "へ" : "he",
            "ほ" : "ho",
            "ま" : "ma",
            "み" : "mi",
            "む" : "mu",
            "め" : "me",
            "も" : "mo",
            "や" : "ya",
            "ゆ" : "yu",
            "よ" : "yo",
            "ら" : "ra",
            "り" : "ri",
            "る" : "ru",
            "れ" : "re",
            "ろ" : "ro",
            "わ" : "wa",
            "を" : "wo",
            "ん" : "nn",
            "ゔ" : "vu",
            "が" : "ga",
            "ぎ" : "gi",
            "ぐ" : "gu",
            "げ" : "ge",
            "ご" : "go",
            "ざ" : "za",
            "じ" : "zi",
            "ず" : "zu",
            "ぜ" : "ze",
            "ぞ" : "zo",
            "だ" : "da",
            "ぢ" : "di",
            "づ" : "du",
            "で" : "de",
            "ど" : "do",
            "ば" : "ba",
            "び" : "bi",
            "ぶ" : "bu",
            "べ" : "be",
            "ぼ" : "bo",
            "ぱ" : "pa",
            "ぴ" : "pi",
            "ぷ" : "pu",
            "ぺ" : "pe",
            "ぽ" : "po",
            "っ" : "tt",
            "ゃ" : "xya",
            "ゅ" : "xyu",
            "ょ" : "xyo",
            "ゎ" : "xwa",
            "ア" : "a",
            "イ" : "i",
            "ウ" : "u",
            "エ" : "e",
            "オ" : "o",
            "カ" : "ka",
            "キ" : "ki",
            "ク" : "ku",
            "ケ" : "ke",
            "コ" : "ko",
            "サ" : "sa",
            "シ" : "si",
            "ス" : "su",
            "セ" : "se",
            "ソ" : "so",
            "タ" : "ta",
            "チ" : "ti",
            "ツ" : "tu",
            "テ" : "te",
            "ト" : "to",
            "ナ" : "na",
            "ニ" : "ni",
            "ヌ" : "nu",
            "ネ" : "ne",
            "ノ" : "no",
            "ハ" : "ha",
            "ヒ" : "hi",
            "フ" : "hu",
            "ヘ" : "he",
            "ホ" : "ho",
            "マ" : "ma",
            "ミ" : "mi",
            "ム" : "mu",
            "メ" : "me",
            "モ" : "mo",
            "ヤ" : "ya",
            "ユ" : "yu",
            "ヨ" : "yo",
            "ラ" : "ra",
            "リ" : "ri",
            "ル" : "ru",
            "レ" : "re",
            "ロ" : "ro",
            "ワ" : "wa",
            "ヲ" : "wo",
            "ン" : "nn",
            "ヴ" : "vu",
            "ガ" : "ga",
            "ギ" : "gi",
            "グ" : "gu",
            "ゲ" : "ge",
            "ゴ" : "go",
            "ザ" : "za",
            "ジ" : "zi",
            "ズ" : "zu",
            "ゼ" : "ze",
            "ゾ" : "zo",
            "ダ" : "da",
            "ヂ" : "di",
            "ヅ" : "du",
            "デ" : "de",
            "ド" : "do",
            "バ" : "ba",
            "ビ" : "bi",
            "ブ" : "bu",
            "ベ" : "be",
            "ボ" : "bo",
            "パ" : "pa",
            "ピ" : "pi",
            "プ" : "pu",
            "ペ" : "pe",
            "ポ" : "po",
            "ッ" : "tt",
            "ャ" : "xya",
            "ュ" : "xyu",
            "ョ" : "xyo",
            "ヮ" : "xwa",
            "ｱ" : "a",
            "ｲ" : "i",
            "ｳ" : "u",
            "ｴ" : "e",
            "ｵ" : "o",
            "ｶ" : "ka",
            "ｷ" : "ki",
            "ｸ" : "ku",
            "ｹ" : "ke",
            "ｺ" : "ko",
            "ｻ" : "sa",
            "ｼ" : "si",
            "ｽ" : "su",
            "ｾ" : "se",
            "ｿ" : "so",
            "ﾀ" : "ta",
            "ﾁ" : "ti",
            "ﾂ" : "tu",
            "ﾃ" : "te",
            "ﾄ" : "to",
            "ﾅ" : "na",
            "ﾆ" : "ni",
            "ﾇ" : "nu",
            "ﾈ" : "ne",
            "ﾉ" : "no",
            "ﾊ" : "ha",
            "ﾋ" : "hi",
            "ﾌ" : "hu",
            "ﾍ" : "he",
            "ﾎ" : "ho",
            "ﾏ" : "ma",
            "ﾐ" : "mi",
            "ﾑ" : "mu",
            "ﾒ" : "me",
            "ﾓ" : "mo",
            "ﾔ" : "ya",
            "ﾕ" : "yu",
            "ﾖ" : "yo",
            "ﾗ" : "ra",
            "ﾘ" : "ri",
            "ﾙ" : "ru",
            "ﾚ" : "re",
            "ﾛ" : "ro",
            "ﾜ" : "wa",
            "ｦ" : "wo",
            "ﾝ" : "nn",
            "ｳﾞ" : "vu",
            "ｶﾞ" : "ga",
            "ｷﾞ" : "gi",
            "ｸﾞ" : "gu",
            "ｹﾞ" : "ge",
            "ｺﾞ" : "go",
            "ｻﾞ" : "za",
            "ｼﾞ" : "zi",
            "ｽﾞ" : "zu",
            "ｾﾞ" : "ze",
            "ｿﾞ" : "zo",
            "ﾀﾞ" : "da",
            "ﾁﾞ" : "di",
            "ﾂﾞ" : "du",
            "ﾃﾞ" : "de",
            "ﾄﾞ" : "do",
            "ﾊﾞ" : "ba",
            "ﾋﾞ" : "bi",
            "ﾌﾞ" : "bu",
            "ﾍﾞ" : "be",
            "ﾎﾞ" : "bo",
            "ﾊﾟ" : "pa",
            "ﾋﾟ" : "pi",
            "ﾌﾟ" : "pu",
            "ﾍﾟ" : "pe",
            "ﾎﾟ" : "po",
            "ｯ" : "tt",
            "ｬ" : "xya",
            "ｭ" : "xyu",
            "ｮ" : "xyo",
        ]
        return table[self]
    }
}

enum KanaType {
    case hirakana
    case katakana
    case hankakuKana
}
let ConversionTable : [KanaType:String] = [
    .hirakana:
        "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉゔがぎぐげござじずぜぞだぢっでどばびぶべぼゃゅょづぱぴぷぺぽー",
    .katakana:
        "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォヴガギグゲゴザジズゼゾダヂッデドバビブベボャュョヅパピプペポー",
    .hankakuKana:
        "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｳﾞｶﾞｷﾞｸﾞｹﾞｺﾞｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾞﾁﾞｯﾃﾞﾄﾞﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞｬｭｮﾂﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟｰ"
]

extension String {
    func conv(_ from : KanaType, to : KanaType) -> String {
        let x = ConversionTable[from] ?? ""
        let y = ConversionTable[to] ?? ""
        return implode(Array(self.characters).map({ (c : Character) -> Character in tr(c, from: x, to: y) ?? c }))
    }

    func conv(_ to : KanaType) -> String {
        var result = Array(self.characters)
        let target = ConversionTable[to] ?? ""
        for (type, table) in ConversionTable {
            if type != to {
                result = result.map({ (c : Character) -> Character in tr(c, from: table, to: target) ?? c })
            }
        }
        return implode(result)
    }

    func toggleDakuten() -> String? {
        let table : [[String?]] = [
            ["あ","い","う","え","お",
             "か","き","く","け","こ",
             "さ","し","す","せ","そ",
             "た","ち","つ","て","と",
             "は","ひ","ふ","へ","ほ",
     	     "や","ゆ","よ","わ",
             "ア","イ","ウ","エ","オ",
             "カ","キ","ク","ケ","コ",
             "サ","シ","ス","セ","ソ",
             "タ","チ","ツ","テ","ト",
             "ハ","ヒ","フ","ヘ","ホ",
             "ヤ","ユ","ヨ","ワ",
             "ｱ","ｲ","ｳ","ｴ","ｵ",
             "ｶ","ｷ","ｸ","ｹ","ｺ",
             "ｻ","ｼ","ｽ","ｾ","ｿ",
             "ﾀ","ﾁ","ﾂ","ﾃ","ﾄ",
             "ﾊ","ﾋ","ﾌ","ﾍ","ﾎ",
             "ﾔ","ﾕ","ﾖ"],
            ["ぁ","ぃ","ぅ","ぇ","ぉ",
             "が","ぎ","ぐ","げ","ご",
             "ざ","じ","ず","ぜ","ぞ",
             "だ","ぢ","っ","で","ど",
             "ば","び","ぶ","べ","ぼ",
             "ゃ","ゅ","ょ","ゎ",
             "ァ","ィ","ゥ","ェ","ォ",
             "ガ","ギ","グ","ゲ","ゴ",
             "ザ","ジ","ズ","ゼ","ゾ",
             "ダ","ヂ","ッ","デ","ド",
             "バ","ビ","ブ","ベ","ボ",
             "ャ","ュ","ョ","ヮ",
             "ｧ","ｨ","ｩ","ｪ","ｫ",
             "ｶﾞ","ｷﾞ","ｸﾞ","ｹﾞ","ｺﾞ",
             "ｻﾞ","ｼﾞ","ｽﾞ","ｾﾞ","ｿﾞ",
             "ﾀﾞ","ﾁﾞ","ｯ","ﾃﾞ","ﾄﾞ",
      	     "ﾊﾞ","ﾋﾞ","ﾌﾞ","ﾍﾞ","ﾎﾞ",
	         "ｬ","ｭ","ｮ"],
            [nil,nil,"ゔ",nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,"づ",nil,nil,
             "ぱ","ぴ","ぷ","ぺ","ぽ",
             nil,nil,nil,nil,
             nil,nil,"ヴ",nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,"ヅ",nil,nil,
             "パ","ピ","プ","ペ","ポ",
             nil,nil,nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,nil,nil,nil,
             nil,nil,"ﾂﾞ",nil,nil,
             "ﾊﾟ","ﾋﾟ","ﾌﾟ","ﾍﾟ","ﾎﾟ",
             nil,nil,nil]]
        return toggle(self, table: table)
    }

    func toggleUpperLower() -> String? {
        let table : [[String?]] = [
            ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"],
            ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]]
        return toggle(self, table: table)
    }

    func first() -> Character? {
        let xs = Array(self.characters)
        return xs.first
    }

    func last() -> String? {
        let xs = Array(self.characters)
        switch xs.last {
        case .some(let last):
            if (last == "ﾞ" || last == "ﾟ") && xs.count > 1 {
                let prev = xs[xs.count - 2]
                return String(prev) + String(last)
            } else {
                return String(last)
            }
        case .none:
       	    return .none
        }
    }

    func butLast() -> String {
        switch self.last() {
        case .none:
            return self
        case .some(let s):
            if(s.utf16.count <= self.utf16.count) {
                return self.substring(to: self.characters.index(self.startIndex, offsetBy: self.utf16.count - s.utf16.count))
            } else {
                return self
            }
        }
    }
}

extension Array {
    func unique <T: Hashable> () -> [T] {
        return uniqueBy { x in x }
    }

    func uniqueBy <S, T: Hashable> (_ f : (S) -> T) -> [S] {
        var result = [S]()
        var addedDict = [T: Bool]()
        for elem in self {
            let t : T = f(elem as! S)
            if addedDict[t as T] == nil {
                addedDict[t as T] = true
                result.append(elem as! S)
            }
        }
        return result
    }

    func any(_ f: (Element) -> Bool) -> Bool {
        for elem in self {
            if f(elem) { return true }
        }
        return false
    }

    func index(_ f: (Element) -> Bool) -> Array.Index? {
        for i in 0..<self.count {
            if f(self[i]) { return i }
        }
        return nil
    }
}
