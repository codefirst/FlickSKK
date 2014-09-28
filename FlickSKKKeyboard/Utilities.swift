//
//  Utilities.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/28.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
import UIKit


extension NSObject {
    func tap<T>(block:(T) -> Void) -> Self {
        block(self as T)
        return self
    }
}


extension UIView {
    func autolayoutFormat(metrics: [String:CGFloat], _ views: [String:UIView]) -> String -> Void {
        return self.autolayoutFormat(metrics, views, options: NSLayoutFormatOptions.allZeros)
    }
    
    func autolayoutFormat(metrics: [String:CGFloat], _ views: [String:UIView], options: NSLayoutFormatOptions) -> String -> Void {
        for v in views.values {
            if !v.isDescendantOfView(self) {
                v.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.addSubview(v)
            }
        }
        return { (format: String) in
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: views))
        }
    }
}


extension UIButton {
    func setBackgroundImage(#color: UIColor, forState state: UIControlState) {
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        color.setFill()
        UIRectFillUsingBlendMode(CGRectMake(0, 0, 1, 1), kCGBlendModeCopy)
        self.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), forState: state)
        UIGraphicsEndImageContext()
    }
}


func dictionaryWithKeyValues<K,V>(pairs: [(K,V)]) -> [K:V] {
    var d: [K:V] = [:]
    for (k, v) in pairs {
        d[k] = v
    }
    return d
}
