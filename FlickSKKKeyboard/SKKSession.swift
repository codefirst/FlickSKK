
//
//  SKKSession.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class SKKSession : BaseSession {
    // 通常モード用
    private weak var delegate : SKKDelegate?
    
    init(delegate : SKKDelegate, dict : SKKDictionary) {
        self.delegate = delegate
        super.init(dict: dict)
    }

    func handle(event : KeyEvent) {
        switch(self.status) {
        case .Default:
            onDefault(event)
        case .WordRegister:
            onWordRegister(event)
        }
        
        switch(self.status) {
        case .Default:
            showInfo(currentInputMode()?.info())
        case .WordRegister:
            showInfo(subSession?.info())
        }        
    }
    
    private func onDefault(event : KeyEvent) {
        let m = currentInputMode()
        processHandles(m?.handle(event) ?? [])
    }
    
    private func onWordRegister(event : KeyEvent) {
        switch subSession?.handle(event) {
        case .Some(.Commit(kanji : let kanji)):
            self.status = .Default
            onDefault(.CommitWord(kanji: kanji))
        case .Some(.Cancel):
            self.status = .Default
            onDefault(.CancelWord)
        case .Some(.Handles(xs: let xs)):
            processHandles(xs)
        case .None:
            ()
        }
    }
    
    private func processHandles(xs : [InputMode.Handle]) {
        for x in xs {
            switch x {
            case .InsertText(text: let text):
                self.delegate?.insertText(text)
            case .DeleteText(count: let count):
                for _ in 0..<count {
                    self.delegate?.deleteBackward()
                }
            case .ToggleDakuten(beforeText : let beforeText):
                let dakuten = beforeText.last()?.toggleDakuten()
                switch dakuten {
                case .Some(let s):
                    // REMARK: 1文字消せば、半角カナも濁点付きで消える
                    self.delegate?.deleteBackward()
                    self.delegate?.insertText(s)
                case .None:
                    ()
                }
            case .ToggleUpperLower(beforeText: let beforeText):
                let s = beforeText.last()?.toggleUpperLower()
                switch s {
                case .Some(let s):
                    self.delegate?.deleteBackward()
                    self.delegate?.insertText(s)
                case .None:
                    ()
                }
            case .InputModeChange(mode: let mode):
                self.currentMode = mode
            case .RegisterWord(kana: let kana, okuri: let okuri):
                registerWord(kana, okuri: okuri)
            }
        }
    }
    
    private func showInfo(info : InputMode.Info?) {
        switch info {
        case .Some(.ComposeText(text: let text)):
            self.delegate?.composeText(text)
            self.delegate?.showCandidates(.None)
        case .Some(.Candidates(xs: let xs)):
            self.delegate?.showCandidates(xs)
        case .None:
            ()
        }
    }
}
