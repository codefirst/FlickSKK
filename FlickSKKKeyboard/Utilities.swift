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
    func tap<T>(block:(T) -> Void) -> Self {
        block(self as T)
        return self
    }
}


extension UIView {
    func autolayoutFormat(metrics: [String:CGFloat], _ views: [String:UIView]) -> String -> Void {
        return self.autolayoutFormat(metrics, views, options: NSLayoutFormatOptions.allZeros)
    }

    func autolayoutFormat(metrics: [String:CGFloat], _ views: [String:UIView], options: NSLayoutFormatOptions) -> String -> Void {
        for v in views.values {
            if !v.isDescendantOfView(self) {
                v.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.addSubview(v)
            }
        }
        return { (format: String) in
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: views))
        }
    }
}


extension UIButton {
    func setBackgroundImage(#color: UIColor, forState state: UIControlState) {
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        color.setFill()
        UIRectFillUsingBlendMode(CGRectMake(0, 0, 1, 1), kCGBlendModeCopy)
        self.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), forState: state)
        UIGraphicsEndImageContext()
    }
}


func dictionaryWithKeyValues<K,V>(pairs: [(K,V)]) -> [K:V] {
    var d: [K:V] = [:]
    for (k, v) in pairs {
        d[k] = v
    }
    return d
}

func toggle(c : Character, table : [String]) -> Character? {
    let skip : Character = "ー"
    for i in 0..<table.count {
        if let r = table[i].rangeOfString(String(c)) {
            var next = table[(i + 1) % table.count][r.startIndex]
            if next == skip {
                next = table[(i + 2) % table.count][r.startIndex]
            }
            return next
        }
    }
    return .None
}

func tr(c : Character, from : String, to : String) -> Character? {
    if let r = from.rangeOfString(String(c)) {
        return to[r.startIndex]
    }
    return .None
}

// FIXME: more effective
func implode(xs : [Character]) -> String {
    var str = ""
    for x in xs {
        str += String(x)
    }
    return str
}

extension Character {
    func toggleDakuten() -> Character? {
        let table = [
            "あいうえおかきくけこさしすせそたちつてとはひふへほやゆよアイウエオカキクケコサシスセソタチツテトハヒフヘホヤユヨ",
            "ぁぃぅぇぉがぎぐげござじずぜぞだぢっでどばびぶべぼゃゅょァィゥェォガギグゲゴザジズゼゾダヂッデドバビブベボャュョ",
            "ーーーーーーーーーーーーーーーーーづーーぱぴぷぺぽーーーーーーーーーーーーーーーーーーーーヅーーパピプペポーーー",
        ]
        return toggle(self, table)
    }

    func toHirakana() -> Character? {
        let from =
            "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォガギグゲゴザジズゼゾダヂッデドバビブベボャュョヅパピプペポ"
        let to =
            "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉがぎぐげござじずぜぞだぢっでどばびぶべぼゃゅょづぱぴぷぽ"
        return tr(self, from, to)
    }

    // remark: you need to normalize
    func toZenkakuKana() -> Character? {
        let from =
            "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯ"
        let to =
            "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォッ"
        return tr(self, from, to)
    }

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
        ]
        return table[self]
    }
}

extension String {
    func fromKatakanaToHirakana() -> String {
        return implode(Array(self).map({ (c : Character) -> Character in c.toHirakana() ?? c }))
    }
    func fromHankakuKanaToKatakana() -> String {
        // TODO: dakuten normalize
        return implode(Array(self).map({ (c : Character) -> Character in c.toZenkakuKana() ?? c }))
    }
}