// 数値変換等の特殊な変換を実現するためのフィルタ。
protocol SKKFilter {
    func call(target : String, binarySearch: BinarySearch, parse : String -> [String]) -> [String]
}