//
//  SKKDictionaryEntry.swift
//  
//
//  Created by MIZUNO Hiroki on 11/4/14.
//
//

import Foundation

enum SKKDictionaryEntry : Comparable  {
    case SKKDictionaryEntry(kanji : String, kana : String, okuri : String?)
}

func ==(l: SKKDictionaryEntry, r: SKKDictionaryEntry) -> Bool {
    switch (l,r)  {
    case (.SKKDictionaryEntry(kanji: let kanji1, kana: let kana1, okuri: let okuri1),
          .SKKDictionaryEntry(kanji: let kanji2, kana: let kana2, okuri: let okuri2)):
        return kanji1 == kanji2 && kana1 == kana2 && okuri1 == okuri2
    }
}

func <(l: SKKDictionaryEntry, r: SKKDictionaryEntry) -> Bool {
    switch (l,r)  {
    case (.SKKDictionaryEntry(kanji: let kanji1, kana: let kana1, okuri: let okuri1),
          .SKKDictionaryEntry(kanji: let kanji2, kana: let kana2, okuri: let okuri2)):
        return kana1 < kana2 || okuri1 < okuri2 || kanji1 < kanji2
    }
}