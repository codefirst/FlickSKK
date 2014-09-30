//
//  InputMode.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

protocol InputMode {
    // 入力の制御
    func handle(event : KeyEvent, shift : Bool, changeMode : SKKInputMode -> ())
}