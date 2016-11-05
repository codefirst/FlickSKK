// 数値変換フィルタ
//
// 検索語が「16や」だった場合、以下のようなエントリをヒットするようにする。
//
//   #や /#1夜/#2夜/
//
// #1 等はそれぞれ「全角数字に変換する」などのルールが決まっている。
class NumberFilter : SKKFilter {
    // 見出し語中に含まれる数字を置換するための正規表現(e.g. 10, 231)
    fileprivate let regexp : NSRegularExpression! = try? NSRegularExpression(pattern: "[0-9]+", options: [])

    // 単語中の #1 等を置換するための正規表現(e.g. #1, #2)
    fileprivate let template : NSRegularExpression! = try? NSRegularExpression(pattern: "#[0-9]", options: [])

    func call(_ target: String, binarySearch: BinarySearch, parse: (String) -> [String]) -> [String] {
        // 検索語の置換のために、数字を記憶する
        let numbers = self.numbers(target)

        if numbers.isEmpty { return [] }

        // 検索する
        if let line = binarySearch.call(self.hashnize(target)) {
            let entries = parse(line)

            // 検索結果を置換する
            return entries.map {
                self.stringnize($0, numbers: numbers)
            }
        } else {
            return []
        }
    }

    // 見出し語中の数値を抜き出す
    fileprivate func numbers(_ value : String) -> [Int64] {
        let xs = regexp.matches(in: value,
            options: [],
            range: NSMakeRange(0, value.utf16.count)) 
        return xs.map({ x in
            let n : NSString = (value as NSString).substring(with: x.range) as NSString
            return n.longLongValue
        })
    }

    // 検索用に変換する: 16や -> #や
    fileprivate func hashnize(_ target : String) -> String {
        return regexp.stringByReplacingMatches(in: target,
            options: [],
            range: NSMakeRange(0, target.utf16.count),
            withTemplate: "#")
    }

    // 単語中の #1 等を置換する
    fileprivate func stringnize(_ entry : String, numbers : [Int64]) -> String {
        let result : NSMutableString =
        entry.mutableCopy() as! NSMutableString

        var ret =
        template.firstMatch(in: result as String, options: [], range: NSMakeRange(0, result.length))

        var index = 0

        while let x = ret {
            let matched = result.substring(with: x.range)

            template.replaceMatches(in: result,
                options: [],
                range: x.range,
                withTemplate: stringFor(numbers[index], entry: matched))
            index += 1
            ret = template.firstMatch(in: result as String, options: [], range: NSMakeRange(0, result.length))
        }

        return result as String
    }

    // #1 等に応じて、対応した文字に変換する
    fileprivate func stringFor(_ n : Int64, entry : String) -> String {
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
}
