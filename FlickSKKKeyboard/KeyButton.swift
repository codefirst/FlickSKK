//
//  KeyButton.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/28.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
import UIKit


class KeyButton: UIView {
    let key: KanaFlickKey
    var sequenceIndex: Int? {
        didSet {
            if let s = key.sequence {
                let text = String(Array(s)[self.sequenceIndex ?? 0])
                // FIXME: special ignore label
                if(text != "-ignore-") {
                    self.label.text = text
                }
            }
        }
    }
    
    let label = UILabel()
    let popup = UILabel()
    var metrics: [String:CGFloat] {
        return [:]
    }
    
    var tapped: ((KanaFlickKey, Int?) -> Void)?
    var selected: Bool {
        didSet {
            self.backgroundColor = selected ? selectedBackgroundColor : normalBackgroundColor
        }
    }
    var enabled: Bool {
        didSet {
            self.userInteractionEnabled = enabled
            self.label.textColor = enabled ? UIColor.blackColor() : UIColor.grayColor()
        }
    }
    
    var normalBackgroundColor: UIColor
    var selectedBackgroundColor: UIColor
    
    init(key: KanaFlickKey) {
        self.key = key
        self.normalBackgroundColor = key.isControl ? UIColor.lightGrayColor() : UIColor(white: 1.0, alpha: 1.0)
        self.selectedBackgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.selected = false
        self.enabled = true
        
        super.init(frame: CGRectZero)
        
        self.backgroundColor = normalBackgroundColor
        
        self.label.tap { (l:UILabel) in
            l.text = self.key.buttonLabel
            l.textColor = UIColor.blackColor()
            l.textAlignment = .Center
            l.font = UIFont.systemFontOfSize(17.0)
        }
        self.layer.tap { (l:CALayer) in
            l.borderColor = UIColor.grayColor().CGColor
            l.borderWidth = 1.0 / UIScreen.mainScreen().scale / 2.0
        }
        
        let views = [
            "label": label,
        ]
        let autolayout = self.autolayoutFormat(metrics, views)
        autolayout("H:|[label]|")
        autolayout("V:|[label]|")
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "gestureTapped:"))
        
        if let _ = key.sequence {
            self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "gesturePanned:"))
        }
    }
    
    func gestureTapped(gesture: UITapGestureRecognizer) {
        self.tapped?(self.key, self.sequenceIndex)
    }
    
    func gesturePanned(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Ended {
            self.tapped?(self.key, self.sequenceIndex)
            self.sequenceIndex = nil
            return
        }
        
        let p = gesture.locationInView(self)
        let s = key.sequence!
        let maxIndex = s.count - 1
        
        if self.bounds.contains(p) {
            self.sequenceIndex = 0
            self.popup.removeFromSuperview() // TODO: show in below block
        } else {
            let angle = Double(atan2(p.y - self.bounds.height/2, p.x - self.bounds.width/2))
            if angle < -3*M_PI_4 || angle >= 3*M_PI_4 {
                self.sequenceIndex = min(1, maxIndex)
            } else if angle < -M_PI_4 {
                self.sequenceIndex = min(2, maxIndex)
            } else if angle < M_PI_4 {
                self.sequenceIndex = min(3, maxIndex)
            } else {
                self.sequenceIndex = min(4, maxIndex)
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
