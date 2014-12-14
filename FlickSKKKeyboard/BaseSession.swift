//
//  BaseSession.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/05.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class BaseSession {
    enum Status {
        // 通常変換
        case Default
        // 辞書登録
        case WordRegister
    }

    var status : Status = .Default

    // 通常モード用
    private let inputMode : [SKKInputMode:InputMode]
    var currentMode : SKKInputMode = .Hirakana
    let dictionary : SKKDictionary

    // 単語登録モード用
    var subSession : WordRegisterSession?

    init(dict : SKKDictionary) {
        self.dictionary = dict
        self.inputMode = [
            .Hirakana:    InputMode(sourceType: .Hirakana,    dictionary: self.dictionary),
            .Katakana:    InputMode(sourceType: .Katakana,    dictionary: self.dictionary),
            .HankakuKana: InputMode(sourceType: .HankakuKana, dictionary: self.dictionary)
        ]
    }

    func currentInputMode() -> InputMode? {
        return self.inputMode[self.currentMode]
    }

    func info() -> InputMode.Info? {
        return .None
    }

    func registerWord(kana : String, okuri : (String, String)?) {
        self.status = .WordRegister
        self.subSession = WordRegisterSession(kana: kana, okuri: okuri, dict: self.dictionary)
    }
}
