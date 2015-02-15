//
//  AppDelegate.swift
//  Memo
//
//  Created by banjun on 2015/02/15.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let vc = ViewController()
        let nc = UINavigationController(rootViewController: vc)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = nc
        self.window?.makeKeyAndVisible()
        return true
    }
}

