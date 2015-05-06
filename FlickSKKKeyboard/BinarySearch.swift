// SKK辞書から該当エントリを二分探索する。
//
// SKK辞書は以下のようなエントリの列となっている。(引用元: 沖縄語辞書)
//
//   あたえ /安多栄;‖姓/
//   あたり /中;@@@‖姓/當;myama_kj@pref98‖姓/
//   あだ /安田;‖各種/
//   あだがーしま /安田ヶ島;国頭村　あだが?‖接尾語付き地名/
//
// ここから目的のエントリを見付けるため、スペースの前の部分に関して二分探索を行なう必要がある。
//
// 既存の二分探索ライブラリでは「スペースの前」という部分に対応していなかったため、自分で実装する。
//
// また送りありエントリは辞書の逆順で格納されているので、比較順を逆にできるオプションも実装する。
class BinarySearch {
    private let entries : NSArray
    private let compare : NSComparisonResult

    init(entries : NSArray, reverse : Bool) {
        self.entries = entries
        self.compare = reverse ?
            NSComparisonResult.OrderedDescending :
            NSComparisonResult.OrderedAscending

    }

    func call(target : NSString) -> String? {
        return binarySearch(target, begin: 0, end: entries.count)
    }

    private func binarySearch(target : NSString, begin : Int, end : Int) -> String? {
        if begin == end { return .None }
        if begin + 1 == end {
            let x = entries[begin] as! NSString
            if x.hasPrefix(target as String) {
                return x as String
            } else {
                return .None
            }
        }

        let mid = (end - begin) / 2 + begin;
        let x  = entries[mid] as! NSString
        if x.hasPrefix(target as String) {
            return x as String
        } else {
            if target.compare(x as String, options: .LiteralSearch) == compare {
                return binarySearch(target, begin: begin, end: mid)
            } else {
                return binarySearch(target, begin: mid, end: end)
            }
        }
    }
}