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

class InputModeBase : InputMode {
    let delegate       : SKKDelegate
    var status         : InputModeStatus = .Default
    let dict           : SKKDictionary
    var candidates     : [String] = []
    var candidateIndex : Int      = 0
    let inlineCandidate : Int = 3
    var composeText    : String   = ""

    init(delegate : SKKDelegate, dict : SKKDictionary) {
        self.delegate = delegate
        self.dict = dict
    }

    func handle(event : KeyEvent, shift: Bool, changeMode: SKKInputMode -> ()) {
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
                switch delegate.lastString()?.toggleDakuten() {
                case .Some(let s):
                    delegate.deleteBackward()
                    delegate.insertText(String(s))
                case .None:
                    ()
                }
            }
        case .KanaCompose:
            switch event {
            case .Char(kana: let kana, roman: let roman):
                if(shift) {
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
                    self.composeText = butLast(self.composeText)
                }
            case .SelectCandidate(_):
                ()
            case .InputModeChange(inputMode: let mode):
                // FIXME: カナ確定など
                ()
            case .ToggleDakuten:
                switch (Array(composeText).last ?? Character("")).toggleDakuten() {
                case .Some(let s):
                    self.composeText = butLast(self.composeText) + String(s)
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
                    // TODO: register dict
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

    func findDict(text : String, okuri : (String, String)?) -> [String]{
        return []
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
            // TODO: register dict
        }
    }

    private func butLast(s : String) -> String {
        return s.substringToIndex(advance(s.startIndex, s.utf16Count - 1))
    }
}