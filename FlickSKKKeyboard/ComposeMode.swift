//
//  ComposeResult.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 2/7/15.
//  Copyright (c) 2015 BAN Jun. All rights reserved.
//

enum ComposeMode {
    case directInput
    case kanaCompose(kana : String, candidates: [Candidate])
    case kanjiCompose(kana : String, okuri : String?, candidates: [Candidate], index : Int)
    case wordRegister(kana : String, okuri : String?, composeText : String, composeMode : [ComposeMode])
}

func ==(l : ComposeMode, r : ComposeMode) -> Bool {
    switch (l,r)  {
    case (.directInput, .directInput):
        return true
    case (.kanaCompose(kana: let kana1, candidates: let candidates1), .kanaCompose(kana: let kana2, candidates: let candidates2)):
        return kana1 == kana2 && candidates1 == candidates2
    case (.kanjiCompose(kana : let kana1, okuri : let okuri1, candidates: let candidates1, index: let index1),
        .kanjiCompose(kana : let kana2, okuri : let okuri2, candidates: let candidates2, index: let index2)):
        return kana1 == kana2 && okuri1 == okuri2 && candidates1 == candidates2 && index1 == index2
    case (.wordRegister(kana : let kana1, okuri : let okuri1, composeText : let composeText1, composeMode: let mode1),
        .wordRegister(kana : let kana2, okuri : let okuri2, composeText : let composeText2, composeMode: let mode2)):
        let m1 : ComposeMode = mode1[0]
        let m2 : ComposeMode = mode2[0]
        return kana1 == kana2 && okuri1 == okuri2 && composeText1 == composeText2 && m1 == m2
    default:
        return false
    }
}
