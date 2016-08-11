class Tempfile {
    private static var count = 0

    class func temp() -> NSURL {
        count += 1

        let dir = NSTemporaryDirectory()
        let basename = NSString(format: "temp%.0f-%d.txt", NSDate.timeIntervalSinceReferenceDate() * 1000.0, count)
        return NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(basename as String)!
    }
}
