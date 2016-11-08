class Tempfile {
    fileprivate static var count = 0

    class func temp() -> URL {
        count += 1

        let dir = NSTemporaryDirectory()
        let basename = NSString(format: "temp%.0f-%d.txt", Date.timeIntervalSinceReferenceDate * 1000.0, count)
        return URL(fileURLWithPath: dir).appendingPathComponent(basename as String)
    }
}
