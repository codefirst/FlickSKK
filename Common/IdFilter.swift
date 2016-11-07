// 何もしないフィルタ。
//
// 他のフィルタで変換されてしまうような要素をそのまま検索するためのフィルタ。
// 例えばNumberFilterでは以下のようなエントリを変換できない。
//
//   16にち /16日/
//
// 上記例は特殊だが、zipcode辞書等では発生しうる。
class IdFilter : SKKFilter {
    func call(_ target: String, binarySearch: BinarySearch, parse: (String) -> [String]) -> [String] {
        if let line = binarySearch.call(target as NSString) {
            return parse(line)
        } else {
            return []
        }
    }
}
