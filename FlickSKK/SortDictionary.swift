// 辞書を再ソートする。
// 辞書ファイルを読み込み、再ソートを行なった上で、保存する。
//
// 辞書の文字コードを変換した後などは、再ソートを行なわないと、正しい変換ができない。
// skkdic-sortコマンドと同等の処理だが、コードレベルでの共通点はない。
class SortDictionary {
    fileprivate let dictionary : LoadLocalDictionary
    init(dictionary : LoadLocalDictionary) {
        self.dictionary = dictionary
    }

    func call(_ dest : URL) {
        if let file = LocalFile(url: dest) {
            file.writeln(";; okuri-ari entries.")
            for line in sorted(dictionary.okuriAri(), reverse: true) {
                let line2 = line as! String
                file.writeln(line2 )
            }

            file.writeln(";; okuri-nasi entries.")
            for line in sorted(dictionary.okuriNasi(), reverse: false) {
                let line2 = line as! String
                file.writeln(line2)
            }
            file.close()
        }
    }

    fileprivate func sorted(_ xs : NSArray, reverse: Bool) -> NSArray {
        return xs.sortedArray(comparator: { (x1, y1) -> ComparisonResult in
            let x2 = x1 as! NSString
            let y2 = y1 as! NSString
            if reverse {
                return y2.compare(x2 as String, options: .literal)
            } else {
                return x2.compare(y2 as String, options: .literal)
            }
        }) as NSArray
    }
}
