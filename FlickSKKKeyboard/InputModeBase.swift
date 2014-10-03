//
//  InputModeBase.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/30.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation


enum InputModeStatus {
    // 通常モード
    case Default
    // ▽モード
    case KanaCompose
    // ▼モード
    case KanjiCompose
}

class RegisterDelegate : SKKDelegate {
    let kana : String
    var kanji : String = ""
    var okuri : (String, String)? = .None
    var compose : String = ""
    let delegate : SKKDelegate
    let commit : (String, (String,String)?, String) -> ()
    let cancel : () -> ()
    var commited = false

    init(kana : String, okuri : (String, String)?, delegate : SKKDelegate, commit : (String,(String,String)?,String) -> (), cancel : () -> ()) {
        self.kana = kana
        self.okuri = okuri
        self.delegate = delegate
        self.commit = commit
        self.cancel = cancel
    }

    func insertText(text : String){
        if text == "\n" {
            commited = true
            commit(kana, okuri, kanji)
        } else {
            kanji += text
            refresh()
        }
    }

    func deleteBackward() {
        if(kanji.isEmpty) {
            commited = true
            cancel()
        } else {
            kanji = kanji.butLast()
            refresh()
        }
    }

    func composeText(text : String) {
        self.compose = text
        refresh()
    }

    func showCandidates(candidates : [String]?) {
        self.delegate.showCandidates(candidates)
    }

    func beforeString() -> String {
        return kanji
    }

    func refresh() {
        if(commited) { return } // FIXME: dirty hack
        let okuriStr = (self.okuri?.0) ?? ""
        self.delegate.composeText("[登録:" + kana + (okuriStr.isEmpty ? "" : "*" + okuriStr) + "]" + kanji + compose)
    }
}

class InputModeBase : InputMode {
    let delegate       : SKKDelegate
    var status         : InputModeStatus = .Default
    let dict           : SKKDictionary
    var candidates     : [String] = []
    var candidateIndex : Int      = 0
    let inlineCandidate : Int = 3
    var composeText    : String   = ""
    var composeOkuri   : (String, String)?  = .None
    let createSession : SKKDelegate -> SKKSession
    var session : SKKSession?
    var onRegister = false

    init(delegate : SKKDelegate, dict : SKKDictionary, session : SKKDelegate -> SKKSession) {
        self.delegate = delegate
        self.dict = dict
        self.createSession = session
    }

    func handle(event : KeyEvent, shift: Bool, changeMode: SKKInputMode -> ()) {
        if(onRegister) {
            self.session?.handle(event, shift: shift)
            return
        }
        switch status {
        case .Default:
            switch event {
            case .Char(kana: let kana, roman: _):
                if(shift) {
                    self.status = .KanaCompose
                    self.composeText = kana
                } else {
                    self.delegate.insertText(kana)
                }
            case .Space:
                self.delegate.insertText(" ")
            case .Enter:
                self.delegate.insertText("\n")
            case .Backspace:
                self.delegate.deleteBackward()
            case .SelectCandidate(_):
                ()
            case .InputModeChange(inputMode: let mode):
                changeMode(mode)
            case .ToggleDakuten:
                let dakuten = delegate.beforeString().last()?.toggleDakuten()
                switch dakuten {
                case .Some(let s):
                    delegate.deleteBackward() // REMARK: 半角カナの場合、濁点付きで消える
                    delegate.insertText(s)
                case .None:
                    ()
                }
            }
        case .KanaCompose:
            switch event {
            case .Char(kana: let kana, roman: let roman):
                if(shift) {
                    self.composeOkuri = (kana,roman)
                    let xs = self.findDict(self.composeText, okuri: (kana,roman))
                    setupCandidates(xs)
                } else {
                    composeText += kana
                }
            case .Space:
                setupCandidates(self.findDict(self.composeText, okuri: .None))
            case .Enter:
                self.delegate.insertText(self.composeText)
                reset()
            case .Backspace:
                if(!self.composeText.isEmpty){
                    self.composeText = self.composeText.butLast()
                } else {
                    reset()
                }
            case .SelectCandidate(_):
                ()
            case .InputModeChange(inputMode: let mode):
                // FIXME: カナ確定など
                ()
            case .ToggleDakuten:
                switch composeText.last()?.toggleDakuten() {
                case .Some(let s):
                    self.composeText = self.composeText.butLast() + String(s)
                case .None:
                    ()
                }
            }
        case .KanjiCompose:
            switch event {
            case .Space:
                if(self.candidateIndex + 1 < self.candidates.count) {
                    self.candidateIndex += 1
                } else {
                    registerDict()
                }
            case .Enter:
                self.delegate.insertText(self.candidates[self.candidateIndex])
                reset()
            case .Char(kana: _, roman: _):
                // TODO: handle special char(e.g. q, x)
                self.delegate.insertText(self.candidates[self.candidateIndex])
                reset()
                self.handle(event, shift: shift, changeMode)
            case .Backspace:
                self.status = .KanaCompose
            case .SelectCandidate(let n):
                self.delegate.insertText(self.candidates[n])
                reset()
            case .InputModeChange(inputMode: _):
                self.delegate.insertText(self.candidates[self.candidateIndex])
            case .ToggleDakuten:
                self.status = .KanaCompose
            }
        }
        refresh()
    }

    private func refresh() {
        if(onRegister) { return } // FIXME: dirty hack to show register mode
        switch status {
        case .Default:
            self.delegate.composeText("")
            self.delegate.showCandidates(.None)
        case .KanaCompose:
            self.delegate.composeText("▽" + self.composeText)
            self.delegate.showCandidates(.None)
        case .KanjiCompose:
            if(self.candidateIndex < self.inlineCandidate) {
                self.delegate.composeText("▼" + self.candidates[self.candidateIndex])
                self.delegate.showCandidates(.None)
            } else {
                self.delegate.showCandidates(.Some(self.candidates))
            }
        }
    }

    func normalizeForDict(s : String) -> String { return s }

    func first(x : String) -> String {
        return String(Array(x)[0])
    }

    func findDict(text : String, okuri : (String, String)?) -> [String]{
        switch okuri {
        case .Some((let kana, let roman)):
            let okuri = first(roman)
            let xs    = dict.find(normalizeForDict(text), okuri: okuri)
            return xs.map({ (x : String)  ->  String in
                return x + kana
            })
        case .None:
            return dict.find(normalizeForDict(text), okuri: .None)
        }
    }

    private func reset() {
        self.candidates = []
        self.candidateIndex = 0
        self.composeText = ""
        self.status = .Default
    }

    private func setupCandidates(xs : [String]) {
        self.candidates = xs
        self.candidateIndex = 0
        if(xs.count != 0) {
            self.status = .KanjiCompose
        } else {
            registerDict()
        }
    }

    private func registerDict() {
        let commit  = { (kana : String, okuri : (String,String)?, kanji : String) -> () in
            self.session = nil
            self.onRegister = false
            self.delegate.insertText(kanji)
            var roman : String? = .None
            switch okuri?.1 {
            case .Some(let c):
                roman = self.first(c)
            case .None:
                ()
            }
            self.dict.register(self.normalizeForDict(kana), okuri: roman , kanji: kanji)
            self.reset()
            self.refresh()
        }
        let cancel = { () -> () in
            self.session = nil
            self.onRegister = false
            self.refresh()
        }
        let delegate = RegisterDelegate(kana : self.composeText, okuri : self.composeOkuri, delegate: self.delegate, commit: commit, cancel : cancel)
        self.session = self.createSession(delegate)
        delegate.refresh() // FIXME: dirty hack
        self.onRegister = true
    }
}
