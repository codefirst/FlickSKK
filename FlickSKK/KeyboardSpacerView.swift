//
//  KeyboardSpacerView.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/03.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit


class KeyboardSpacerView : UIView {
    var keyboardHeightConstraint: NSLayoutConstraint?

    func installKeyboardHeightConstraint() {
        keyboardHeightConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: superview,
            attribute: NSLayoutAttribute.Height,
            multiplier: 0,
            constant: 0)
        addConstraint(keyboardHeightConstraint!)

        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: nil) { (n: NSNotification!) -> Void in
            if let userInfo = n.userInfo {
                if let f = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)?.CGRectValue() {
                    self.keyboardHeightConstraint?.constant = f.size.height
                }
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
