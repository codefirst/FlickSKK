//
//  InputModeBase.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/30.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class InputMode {
    enum InputModeStatus {
        // 通常モード
        case Default
        // ▽モード
        case KanaCompose
        // ▼モード
        case KanjiCompose
        // 登録モード中
        case WordRegister
    }

    enum Handle {
        case DeleteText(count : Int)
        case InsertText(text : String)
        case ToggleDakuten(beforeText : String)
        case ToggleUpperLower(beforeText : String)
        case InputModeChange(mode: SKKInputMode)
        case RegisterWord(kana : String, okuri : (String, String)?)
    }

    enum Info {
        case ComposeText(text : String)
        case Candidates(xs : [String]?)
    }

    // 状態遷移の管理
    private var sourceType : KanaType = .Hirakana
    private let dictionary : SKKDictionary
    private var status     : InputModeStatus = .Default

    // KanaComposeモード用
    // FIXME: InputModeStatusの引数にしたほうがいいのでは
    private var composeText  : String = ""
    private var composeOkuri : (String, String)?  = .None

    // KanjiCompose用
    private let INLINE_CANDIDATES = 1
    var candidates     : [String] = []
    var candidateIndex : Int      = 0

    // WordRegister用
    private var oldStatus : InputModeStatus = .Default

    init(dictionary : SKKDictionary) {
        self.dictionary = dictionary
    }

    // factory methods
    private func insertText(text : String) -> [Handle] {
        return [.InsertText(text: text)]
    }

    private func deleteText(n : Int) -> [Handle] {
        return [.DeleteText(count : n)]
    }

    private func registerWord(kana : String, okuri : (String, String)?) -> [Handle] {
        if self.status != .WordRegister {
            self.oldStatus = self.status
        }
        self.status = .WordRegister
        return [.RegisterWord(kana : kana, okuri : okuri)]
    }

    private func done() -> [Handle] {
        return []
    }

    private func withReset<T>(x : T) -> T {
        self.composeText  = ""
        self.composeOkuri = .None
        self.status       = .Default
        self.candidates   = []
        self.candidateIndex = 0
        return x
    }

    // 現在の状態
    func info() -> Info {
        switch status {
        case .Default:
            return .ComposeText(text: "")
        case .KanaCompose:
            return .ComposeText(text: "▽" + self.composeText)
        case .KanjiCompose:
            if(self.candidateIndex < INLINE_CANDIDATES) {
                return .ComposeText(text: "▼" + self.candidates[self.candidateIndex])
            } else {
                return .Candidates(xs: self.candidates)
            }
        case .WordRegister:
            return .ComposeText(text: "oops")
        }
    }

    // イベント制御
    func handle(event : KeyEvent) -> [Handle] {
        switch status {
        case .Default:
            return onDefault(event)
        case .KanaCompose:
            return onKanaCompose(event)
        case .KanjiCompose:
            return onKanjiCompose(event)
        case .WordRegister:
            return onWordRegister(event)
        }
    }

    private func onDefault(event : KeyEvent) -> [Handle] {
        switch event {
        case .Char(kana: let kana, roman: _, shift : let shift):
            if(shift) {
                self.status = .KanaCompose
                self.composeText = kana
                return done()
            } else {
                return insertText(kana)
            }
        case .Space:
            return insertText(" ")
        case .Enter:
            return insertText("\n")
        case .Backspace:
            return deleteText(1)
        case .InputModeChange(inputMode: let mode):
            switch mode {
            case .Hirakana:
                self.sourceType = .Hirakana
            case .Katakana:
                self.sourceType = .Katakana
            case .HankakuKana:
                self.sourceType = .HankakuKana
            }
            return [.InputModeChange(mode: mode)]
        case .ToggleDakuten(beforeText : let beforeText):
            return [.ToggleDakuten(beforeText: beforeText)]
        case .ToggleUpperLower(beforeText: let beforeText):
            return [.ToggleUpperLower(beforeText: beforeText)]
        case .CommitWord(_):
            return done()
        case .CancelWord:
            return done()
        case .SelectCandidate(_):
            return done()
        }
    }

    private func onKanaCompose(event : KeyEvent) -> [Handle] {
        switch event {
        case .Char(kana: let kana, roman: let roman, shift: let shift):
            // REMARK: ignore shift for non-roman character(e.g. 1,2,3)
            if(shift && !roman.isEmpty) {
                self.composeOkuri = (kana,roman)
                let xs = consult(self.composeText, okuri: (kana,roman))
                if(xs.isEmpty) {
                    return registerWord(self.composeText, okuri: self.composeOkuri)
                } else {
                    setupCandidates(xs)
                    return done()
                }
            } else {
                self.composeText += kana
                return done()
            }
        case .Space:
            let xs = consult(self.composeText, okuri: .None)
            if(xs.isEmpty) {
                return registerWord(self.composeText, okuri: self.composeOkuri)
            } else {
                setupCandidates(xs)
                return done()
            }
        case .Enter:
            return withReset(insertText(self.composeText))
        case .Backspace:
            self.composeText = self.composeText.butLast()
            if !self.composeText.isEmpty {
                return done()
            } else {
                return withReset(done())
            }
        case .InputModeChange(inputMode: let mode):
            var t = ""
            switch(mode) {
            case .Hirakana:
                t = self.composeText.conv(self.sourceType, to: .Hirakana)
            case .Katakana:
                t = self.composeText.conv(self.sourceType, to: .Katakana)
            case .HankakuKana:
                t = self.composeText.conv(self.sourceType, to: .HankakuKana)
            }
            return withReset(insertText(t))
        case .ToggleDakuten:
            switch composeText.last()?.toggleDakuten() {
            case .Some(let s):
                self.composeText = self.composeText.butLast() + String(s)
                return done()
            case .None:
                return done()
            }
        case .ToggleUpperLower(_):
            switch composeText.last()?.toggleUpperLower() {
            case .Some(let s):
                self.composeText = self.composeText.butLast() + String(s)
                return done()
            case .None:
                return done()
            }
        case .CommitWord(kanji: let kanji):
            return done()
        case .CancelWord:
            return done()
        case .SelectCandidate(_):
            return done()
        }
    }

    private func onKanjiCompose(event : KeyEvent) -> [Handle] {
        switch event {
        case .Space:
            if(self.candidateIndex + 1 < self.candidates.count) {
                self.candidateIndex += 1
                return done()
            } else {
                return registerWord(self.composeText, okuri: self.composeOkuri)
            }
        case .Enter:
            return withReset(insertText(self.candidates[self.candidateIndex]))
        case .Char(kana: _, roman: _, shift: _):
            // TODO: handle special char(e.g. q, x)
            let x = withReset(insertText(self.candidates[self.candidateIndex]))
            let y = self.handle(event)
            return x + y
        case .Backspace:
            self.status = .KanaCompose
            return done()
        case .SelectCandidate(let n):
            if self.candidates.count <= n {
                // NOTES: 最後には、単語登録用の仮想エントリがあるはず。
                return registerWord(self.composeText, okuri: self.composeOkuri)
            } else {
                return withReset(insertText(self.candidates[n]))
            }
        case .CommitWord(kanji: _):
            return done()
        case .CancelWord:
            return done()
        case .ToggleDakuten:
            switch self.composeOkuri?.0.toggleDakuten() {
            case .Some(let str):
                let c = Array(str)[0]
                self.composeOkuri = (str, c.toRoman() ?? "")
                let xs = consult(self.composeText, okuri: self.composeOkuri)
                if(xs.isEmpty) {
                    return registerWord(self.composeText, okuri: self.composeOkuri)
                } else {
                    setupCandidates(xs)
                    return done()
                }
            case .None:
                return done()
            }
        case .InputModeChange(inputMode: _):
            return done()
        case .ToggleUpperLower(beforeText: _):
            return done()
        }
    }

    func onWordRegister(event : KeyEvent) -> [Handle] {
        switch event {
        case .CommitWord(kanji: let kanji):
            return withReset(insertText(kanji))
        case .ToggleDakuten:
            switch self.composeOkuri?.0.toggleDakuten() {
            case .Some(let str):
                let c = Array(str)[0]
                self.composeOkuri = (str, c.toRoman() ?? "")
                let xs = consult(self.composeText, okuri: self.composeOkuri)
                if(xs.isEmpty) {
                    return registerWord(self.composeText, okuri: self.composeOkuri)
                } else {
                    setupCandidates(xs)
                    return done()
                }
            case .None:
                return done()
            }
        case .CancelWord:
            self.status = self.oldStatus
            return done()
        // ignore
        case .Space:
            return done()
        case .Enter:
            return done()
        case .Char(kana: _, roman: _, shift: _):
            return done()
        case .Backspace:
            return done()
        case .SelectCandidate(let n):
            return done()
        case .InputModeChange(inputMode: _):
            return done()
        case .ToggleUpperLower(beforeText: _):
            return done()
        }
    }

    // 辞書
    func consult(text : String, okuri : (String, String)?) -> [String]{
        let t = text.conv(self.sourceType, to: .Hirakana)
        switch okuri {
        case .Some((let kana, let roman)):
            let okuri : String? = roman.isEmpty ? .None : .Some(String(Array(roman)[0]))
            var xs    = self.dictionary.find(t, okuri: okuri).map({ (x : String)  ->  String in
                return x + kana
            })
            if okuri != .None && t.last() == "っ" {
                // 「っ」送り仮名の場合の特殊処理
                // https://github.com/codefirst/FlickSKK/issues/27
                let ys = self.dictionary.find(t.butLast(), okuri: okuri).map({ (y : String)  ->  String in
                    return y + "っ" + kana
                })
                xs += ys
            }
            return xs
        case .None:
            return self.dictionary.find(t, okuri: .None)
        }
    }

    private func setupCandidates(xs : [String]) {
        if xs.isEmpty {
            self.candidates     = []
            self.candidateIndex = 0
        } else {
            self.candidates     = xs
            self.candidateIndex = 0
            self.status = .KanjiCompose
        }
    }
}
