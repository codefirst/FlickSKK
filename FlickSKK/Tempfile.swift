class Tempfile {
    private static var count = 0

    class func temp() -> String {
        count += 1

        let dir = NSTemporaryDirectory()
        let basename = NSString(format: "temp%.0f-%d.txt", NSDate.timeIntervalSinceReferenceDate() * 1000.0, count)
        return dir.stringByAppendingPathComponent(basename as String)
    }
}