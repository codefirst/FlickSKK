//
//  ViewController.swift
//  Memo
//
//  Created by banjun on 2015/02/15.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let textView = UITextView()
    
    override func loadView() {
        super.loadView()
        
        self.textView.backgroundColor = UIColor.whiteColor()
        self.textView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.textView.font = Appearance.normalFont(20.0)
        self.textView.frame = self.view.bounds
        self.view.addSubview(self.textView)
    }
}

