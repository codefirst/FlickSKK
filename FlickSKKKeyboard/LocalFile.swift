// ローカルにUTF8のテキストファイルに書き出すためのクラス。
// NSFileManagerをラップして、ファイルが存在しているかどうかを気にせずに使えるようにした。
//
// 「ローカル」という命名はiCloud対応を意識してのことだが、現時点で特にそのような仕組みは実装していない。
class LocalFile {
    private let handle : NSFileHandle?

    init?(path : String) {
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes:nil)
        }

        if let handle = NSFileHandle(forWritingAtPath: path) {
            self.handle = handle
            // ファイルを開くと内容を空にするようにする。
            clear()
        } else {
            self.handle = nil
            return nil
        }
    }

    func writeln(str : String) {
        write(str + "\n")
    }

    func write(str : String) {
        let s = str as NSString
        let data = NSData(bytes: s.UTF8String,
            length: s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        handle?.writeData(data)
    }

    func close() {
        self.handle?.closeFile()
    }

    func clear() {
        self.handle?.truncateFileAtOffset(0)
    }
}