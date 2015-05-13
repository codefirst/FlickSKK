// 辞書を再ソートする。
// 辞書ファイルを読み込み、再ソートを行なった上で、保存する。
//
// 辞書の文字コードを変換した後などは、再ソートを行なわないと、正しい変換ができない。
// skkdic-sortコマンドと同等の処理だが、コードレベルでの共通点はない。
class SortDictionary {
    private let path : String
    init(path: String) {
        self.path = path
    }

    func call(dest : String) {
        let dictionary = LoadLocalDictionary(path: path)
        if let file = LocalFile(path: dest) {
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

    private func sorted(xs : NSArray, reverse: Bool) -> NSArray {
        return xs.sortedArrayUsingComparator({ (x1, y1) -> NSComparisonResult in
            let x2 = x1 as! NSString
            let y2 = y1 as! NSString
            if reverse {
                return y2.compare(x2 as String, options: .LiteralSearch)
            } else {
                return x2.compare(y2 as String, options: .LiteralSearch)
            }
        })
    }
}