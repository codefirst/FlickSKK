//
//  SKKDelegate.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

protocol SKKDelegate : AnyObject {
    // 確定文字の表示
    func insertText(_ text : String)

    // 削除
    func deleteBackward()

    // 未確定文字の表示
    func composeText(_ text :String?, markedText: String?)

    // 入力モードの変更
    func changeInputMode(_ inputMode : SKKInputMode)

    // 変換候補の表示
    func showCandidates(_ candidates : [Candidate]?)
}
