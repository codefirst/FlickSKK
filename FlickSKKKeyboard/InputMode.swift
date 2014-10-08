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
    }

    enum Handle {
        case DeleteText(count : Int)
        case InsertText(text : String)
        case InputModeChange(mode: SKKInputMode)
        case RegisterWord(kana : String, okuri : (String, String)?)
    }

    enum Info {
        case ComposeText(text : String)
        case Candidates(xs : [String]?)
    }

    // 状態遷移の管理
    private let sourceType : KanaType
    private let dictionary : SKKDictionary
    private var status     : InputModeStatus = .Default

    // KanaComposeモード用
    private var composeText  : String = ""
    private var composeOkuri : (String, String)?  = .None

    // KanjiCompose用
    private let INLINE_CANDIDATES = 3
    private var candidates     : [String] = []
    private var candidateIndex : Int      = 0

    init(sourceType : KanaType, dictionary : SKKDictionary){
        self.sourceType = sourceType
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
            return [.InputModeChange(mode: mode)]
        case .ToggleDakuten(beforeText : let beforeText):
            let dakuten = beforeText.last()?.toggleDakuten()
            switch dakuten {
            case .Some(let s):
                // REMARK: 1文字消せば、半角カナも濁点付きで消える
                return deleteText(1) + insertText(s)
            case .None:
                return done()
            }
        case .ToggleUpperLower(beforeText: let beforeText):
            let s = beforeText.last()?.toggleUpperLower()
            switch s {
            case .Some(let s):
                return deleteText(1) + insertText(s)
            case .None:
                return done()
            }
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
            if(!self.composeText.isEmpty){
                self.composeText = self.composeText.butLast()
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
            return withReset(insertText(kanji))
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
            return withReset(insertText(self.candidates[n]))
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
            let xs    = self.dictionary.find(t, okuri: okuri)
            return xs.map({ (x : String)  ->  String in
                return x + kana
            })
        case .None:
            return self.dictionary.find(t, okuri: .None)
        }
    }
    
    private func setupCandidates(xs : [String]) {
        self.candidates     = xs
        self.candidateIndex = 0
        if(xs.count != 0) {
            self.status = .KanjiCompose
        }
    }
}
