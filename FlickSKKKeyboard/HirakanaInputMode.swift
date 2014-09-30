//
//  HankakuInputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
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

class HirakanaInputMode : InputMode {
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
            }
        case .KanaCompose:
            switch event {
            case .Char(kana: let kana, roman: let roman):
                if(shift) {
                    let okuri = roman.substringToIndex(advance(roman.startIndex, 1))
                    let xs    = dict.find(self.composeText, okuri: okuri)
                    let ys    = xs.map({ (x : String)  ->  String in
                        return x + kana
                    })
                    setupCandidates(ys)
                } else {
                    composeText += kana
                }
            case .Space:
                setupCandidates(dict.find(self.composeText, okuri: .None))
            case .Enter:
                self.delegate.insertText(self.composeText)
                reset()
            case .Backspace:
                let length = self.composeText.utf16Count
                if(0 < length) {
                    self.composeText = self.composeText.substringToIndex(
                        advance(self.composeText.startIndex, length - 1))
                }
            case .SelectCandidate(_):
                ()
            case .InputModeChange(inputMode: let mode):
                // FIXME:xxx
                ()
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
}
