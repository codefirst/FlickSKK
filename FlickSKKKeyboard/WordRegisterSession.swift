//
//  WordRegisterSession.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/05.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class WordRegisterSession : BaseSession {
    enum Handle {
        case Commit(kanji : String)
        case Cancel
        case Handles(xs : [InputMode.Handle])
    }
    
    // === 通常モード ===
    // よみがな
    private let kana  : String
    // 送り仮名
    private let okuri : (String, String)?
    // 漢字
    private var kanji : String = ""
    
    init(kana : String, okuri : (String, String)?, dict : SKKDictionary) {
        self.kana  = kana
        self.okuri = okuri
        super.init(dict: dict)
    }
    
    func handle(event : KeyEvent) -> Handle {
        let m = currentInputMode()
        switch(self.status) {
        case .Default:
            return onDefault(event)
        case .WordRegister:
            return onRegisterWord(event)
        }
    }
    
    private func onDefault(event : KeyEvent) -> Handle {
        let m = currentInputMode()
        var xs : [InputMode.Handle] = []
        for h in m?.handle(event) ?? [] {
            switch h {
            case .InsertText(text: let text):
                if(text == "\n") {
                    self.dictionary.register(self.kana, okuri: self.okuri?.1, kanji: kanji)
                    return .Commit(kanji: kanji)
                } else {
                    self.kanji += text
                }
            case .DeleteText(count: let count):
                if(kanji.isEmpty) {
                    return .Cancel
                } else {
                    self.kanji = self.kanji.butLast()
                }
            case .InputModeChange(mode: let mode):
                xs.append(.InputModeChange(mode: mode))
            case .RegisterWord(kana: let kana, okuri: let okuri):
                registerWord(kana, okuri: okuri)
            }
        }
        return .Handles(xs: xs)
    }
    
    private func onRegisterWord(event : KeyEvent) -> Handle {
        switch subSession?.handle(event) {
        case .Some(.Commit(kanji : let kanji)):
            self.status = .Default
            return onDefault(.CommitWord(kanji: kanji))
        case .Some(.Cancel):
            self.status = .Default
            return onDefault(.CancelWord)
        case .Some(.Handles(xs: let xs)):
            return .Handles(xs : xs)
        case .None:
            return .Handles(xs : [])
        }
    }
    
    override func info() -> InputMode.Info? {
        var info : InputMode.Info? = .None
        switch status {
        case .Default:
            info = currentInputMode()?.info()
        case .WordRegister:
            info = subSession?.info()
        }
        switch info {
        case .None:
            return .None
        case .Some(.ComposeText(text : let text)):
            let okuriStr = (self.okuri?.0) ?? ""
            return .ComposeText(text: "[登録:" + kana + (okuriStr.isEmpty ? "" : "*" + okuriStr) + "]" + kanji + text)
        case .Some(.Candidates(xs : let xs)):
            return .Candidates(xs: xs)
        }
    }
}