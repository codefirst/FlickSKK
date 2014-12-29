//
//  SKKNumberPreprocess.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 12/26/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

class SKKNumberPreprocessor {
    private let value : String
    private var numbers : [Int] = []

    private let regexp : NSRegularExpression! =
        NSRegularExpression(pattern: "[0-9]+", options: nil, error: nil)

    private let template : NSRegularExpression! =
        NSRegularExpression(pattern: "#[0-9]", options: nil, error: nil)

    init(value : String) {
        self.value = value
    }

    func preProcess() -> String {
        self.numbers = self.findNumbers(value)
        return regexp.stringByReplacingMatchesInString(value,
            options: nil,
            range: NSMakeRange(0, value.utf16Count),
            withTemplate: "#")
    }

    func postProcess(entry : NSString) -> String {
        var result : NSMutableString =
            entry.mutableCopy() as NSMutableString

        var ret =
            template.firstMatchInString(result, options: nil, range: NSMakeRange(0, result.length))

        var index = 0

        while let x = ret {
            let matched = result.substringWithRange(x.range)

            template.replaceMatchesInString(result,
                options: nil,
                range: x.range,
                withTemplate: stringFor(numbers[index], entry: matched))
            index += 1
            ret = template.firstMatchInString(result, options: nil, range: NSMakeRange(0, result.length))
        }

        return result
    }

    private func stringFor(n : Int, entry : String) -> String {
        let formatter = NumberFormatter(value: n)
        switch entry {
        case "#0":
            return formatter.asAscii()
        case "#1":
            return formatter.asFullWidth()
        case "#2":
            return formatter.asJapanese()
        case "#3":
            return formatter.asKanji()
        default:
            return entry
        }
    }

    private func findNumbers(value : String) -> [Int] {
        let xs = regexp.matchesInString(value,
            options: nil,
            range: NSMakeRange(0, value.utf16Count)) as [NSTextCheckingResult]
        return xs.map({ x in
            let n : NSString = (self.value as NSString).substringWithRange(x.range)
            return n.integerValue
        })
    }
}
