//
//  SKKDictionaryEntry.swift
//
//
//  Created by MIZUNO Hiroki on 11/4/14.
//
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum SKKDictionaryEntry : Comparable  {
    case skkDictionaryEntry(kanji : String, kana : String, okuri : String?)
}

func ==(l: SKKDictionaryEntry, r: SKKDictionaryEntry) -> Bool {
    switch (l,r)  {
    case (.skkDictionaryEntry(kanji: let kanji1, kana: let kana1, okuri: let okuri1),
          .skkDictionaryEntry(kanji: let kanji2, kana: let kana2, okuri: let okuri2)):
        return kanji1 == kanji2 && kana1 == kana2 && okuri1 == okuri2
    }
}

func <(l: SKKDictionaryEntry, r: SKKDictionaryEntry) -> Bool {
    switch (l,r)  {
    case (.skkDictionaryEntry(kanji: let kanji1, kana: let kana1, okuri: let okuri1),
          .skkDictionaryEntry(kanji: let kanji2, kana: let kana2, okuri: let okuri2)):
        return kana1 < kana2 || okuri1 < okuri2 || kanji1 < kanji2
    }
}
