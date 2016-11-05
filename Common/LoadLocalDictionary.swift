// SKKの辞書ファイルをロードする。
//
// SKK辞書は以下の形式でテキストファイルに格納されている。
//
//   ;; -*- mode: fundamental; coding: euc-jp -*-
//   ;; Large size dictionary for SKK system
//   ;; Copyright (C) 1988-1995, 1997, 1999-2014
//   (snip)
//   ;; okuri-ari entries.
//   をs /惜/
//   ゐr /居/
//   われらg /我等/
//   われしr /我知/
//   (snip)
//   ;; okuri-nasi entries.
//   ! /！/感嘆符/
//   !! /！！/
//   != /≠/
//   " /″;second/“;doublequote(open)/”;doublequote(close)/〃;繰り返し記号/
//   # /#1/#3/#2/＃;number/#0/#8/#4/#5/
//
// こういったテキストファイルを読み込み、送りありのエントリと、送りなしのエントリを配列として返す。
//
// おもに速度向上・メモリ節約を目的として
//
//  - まとめて読むのではなく、一行づつ読み込む。(ちゃんとベンチマークしてない)
//  - ソート順の変更や、文字コードの変更は行なわず、必要になるまで遅延する。
//  - 行の内容のパースも、必要になるまで遅延する。
//  - Swiftの配列はシミュレータ環境では遅いため、NSArray/NSMutableArrayを利用する
//
// といったことを行なっている。
class LoadLocalDictionary {
    fileprivate var ari : NSMutableArray = NSMutableArray()
    fileprivate var nasi : NSMutableArray = NSMutableArray()

    init(url : URL) {
        guard let path = url.path else { return }

        var isOkuriAri = true
        IOUtil.each(path, with: { line -> Void in
            let s = line as NSString
            // toggle
            if s.hasPrefix(";; okuri-nasi entries.") {
                isOkuriAri = false
            }
            // skip comment
            if s.hasPrefix(";") { return }

            // skip empty line
            if s == "" { return }

            if isOkuriAri {
                self.ari.add(line)
            } else {
                self.nasi.add(line)
            }
        })
    }

    func okuriAri() -> NSArray {
        return ari
    }

    func okuriNasi() -> NSArray {
        return nasi
    }

    func count() -> Int {
        return ari.count + nasi.count
    }
}
