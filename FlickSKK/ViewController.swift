//
//  ViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let textView = UITextView()
    
    var metrics : [String:CGFloat] {
        return [:]
    }
    
    override func loadView() {
        super.loadView()
        
        self.title = NSLocalizedString("FlickSKK", comment: "")
        edgesForExtendedLayout = .None

        textView.backgroundColor = UIColor.whiteColor()
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.systemFontOfSize(18)
        
        let keyboardSpacer = KeyboardSpacerView()
        
        let views = [
            "textView": textView,
            "keyboardSpacer": keyboardSpacer,
        ]
        let autolayout = view.autolayoutFormat(metrics, views)
        autolayout("H:|[textView]|")
        autolayout("V:|[textView][keyboardSpacer]|")
        keyboardSpacer.installKeyboardHeightConstraint()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
}

