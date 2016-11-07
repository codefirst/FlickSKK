// ローカルにUTF8のテキストファイルに書き出すためのクラス。
// NSFileManagerをラップして、ファイルが存在しているかどうかを気にせずに使えるようにした。
//
// 「ローカル」という命名はiCloud対応を意識してのことだが、現時点で特にそのような仕組みは実装していない。
class LocalFile {
    fileprivate let handle : FileHandle?

    init?(url : URL) {
        let path = url.path

        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes:nil)
        }

        if let handle = FileHandle(forWritingAtPath: path) {
            self.handle = handle
            // ファイルを開くと内容を空にするようにする。
            clear()
        } else {
            self.handle = nil
            return nil
        }
    }

    func writeln(_ str : String) {
        write(str + "\n")
    }

    func write(_ str : String) {
        let s = str as NSString
        let data = Data(bytes: UnsafeRawPointer(s.utf8String!),
            count: s.lengthOfBytes(using: String.Encoding.utf8.rawValue))
        handle?.write(data)
    }

    func close() {
        self.handle?.closeFile()
    }

    func clear() {
        self.handle?.truncateFile(atOffset: 0)
    }
}
