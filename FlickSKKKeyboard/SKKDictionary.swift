//
//  SKKDictionary.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class SKKDictionary : NSObject {
    private var initialized = false

    var dictionaries : [ SKKDictionaryFile ] = []
    var userDict : SKKUserDictionaryFile?
    var learnDict : SKKUserDictionaryFile?

    dynamic var isWaitingForLoad : Bool = false
    class func isWaitingForLoadKVOKey() -> String { return "isWaitingForLoad" }

    init(userDict: String, learnDict : String, dicts : [String]){
        super.init()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.userDict = SKKUserDictionaryFile(path: userDict)
            self.learnDict = SKKUserDictionaryFile(path: learnDict)
            self.dictionaries = [ self.learnDict!, self.userDict! ] + dicts.map({ x -> SKKDictionaryFile in
                SKKLocalDictionaryFile(path: x)})
            self.initialized = true
        })
    }

    func find(normal : String, okuri : String?) -> [ String ] {
        self.waitForLoading()

        let xs : [String] = self.dictionaries.map({(dict : SKKDictionaryFile) -> [String] in
            dict.find(normal, okuri: okuri)
        }).reduce([],
                  combine: {(x : [String], y : [String]) -> [String] in
            x + y
        }).unique()

        return xs
    }

    func register(normal : String, okuri: String?, kanji: String) {
        userDict?.register(normal, okuri: okuri, kanji: kanji)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.userDict?.serialize()
            ()
        })
    }

    func learn(normal : String, okuri: String?, kanji: String) {
        learnDict?.register(normal, okuri: okuri, kanji: kanji)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.learnDict?.serialize()
            ()
        })
    }

    func waitForLoading() {
        if initialized { return }

        self.isWaitingForLoad = true
        while !self.initialized {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
        }
        self.isWaitingForLoad = false
    }
}
