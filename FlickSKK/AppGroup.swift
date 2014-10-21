//
//  AppGroup.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation


class AppGroup {
    class func pathForResource(subpath: String) -> String? {
        let userName = AppGroupSupport.userName()
        let identifier = "group.org.codefirst.skk.\(userName).FlickSKK"
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(identifier)?.path?.stringByAppendingPathComponent(subpath)
    }
}