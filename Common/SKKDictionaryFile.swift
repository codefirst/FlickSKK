//
//  SKKDictionaryFile.swift
//  FlickSKK
//
//  Created by mzp on 2014/10/17.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

protocol SKKDictionaryFile {
    func find(_ normal : String, okuri : String?) -> [ String ]
}
