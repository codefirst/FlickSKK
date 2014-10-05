//
//  KeyButton.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/28.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
import UIKit

let KeyButtonHighlightedColor = UIColor(hue: 0.10, saturation: 0.07, brightness: 0.96, alpha: 1.0)


class KeyButton: UIView, UIGestureRecognizerDelegate {
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
    var metrics: [String:CGFloat] {
        return [:]
    }
    
    var tapped: ((KanaFlickKey, Int?, withShift: Bool) -> Void)?
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
    var highlighted: Bool {
        didSet {
            self.backgroundColor = highlighted ? KeyButtonHighlightedColor : selected ? selectedBackgroundColor : normalBackgroundColor
        }
    }
    
    var doubleTapGesture: UITapGestureRecognizer!
    var doubleTapPanGesture: UIPanGestureRecognizer!
    
    var normalBackgroundColor: UIColor
    var selectedBackgroundColor: UIColor
    
    init(key: KanaFlickKey) {
        self.key = key
        self.normalBackgroundColor = key.isControl ? UIColor.lightGrayColor() : UIColor(white: 1.0, alpha: 1.0)
        self.selectedBackgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.selected = false
        self.enabled = true
        self.highlighted = false
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: "gestureTapped:").tap {
            (g: UITapGestureRecognizer) in
            self.addGestureRecognizer(g)
        }
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "gesturePanned:"))
        
        // double-tap or double-tap-and-pan to input with shift
        if key.sequence != nil {
            self.doubleTapGesture = UITapGestureRecognizer(target: self, action: "gestureTapped:").tap {
                (g: UITapGestureRecognizer) in
                g.delegate = self
                g.numberOfTapsRequired = 2
                self.addGestureRecognizer(g)
            }
            self.doubleTapPanGesture = UIPanGestureRecognizer(target: self, action: "gesturePanned:").tap {
                (g: UIPanGestureRecognizer) in
                g.delegate = self
                tap.requireGestureRecognizerToFail(g)
                self.addGestureRecognizer(g)
            }
        }
    }
    
    // MARK: - Gestures
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.highlighted = true // set to false on end, cancel, started pan
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.highlighted = false
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
//        self.highlighted = false // surpress flicker (highlighted = false, then true)
        super.touchesCancelled(touches, withEvent: event)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        println("tapCount = \(touch.tapCount)")
        if (gestureRecognizer === doubleTapGesture) {
            return (touch.tapCount <= 2)
        } else if (gestureRecognizer === doubleTapPanGesture) {
            return (touch.tapCount >= 2)
        }
        return false
    }
    
    func gestureTapped(gesture: UITapGestureRecognizer) {
        let doubleTapped = (gesture === self.doubleTapGesture)
        println("tapped: double = \(doubleTapped)")
        
        KeyButtonFlickPopup.sharedInstance.hide()
        self.highlighted = false
        
        if doubleTapped {
            self.tapped?(KanaFlickKey.Backspace, nil, withShift: false)
        }
        self.tapped?(self.key, self.sequenceIndex, withShift: doubleTapped)
    }
    
    func gesturePanned(gesture: UIPanGestureRecognizer) {
        let doubleTapPanned = (gesture === self.doubleTapPanGesture)
        let p = gesture.locationInView(self)
        
        if gesture.state == .Began && doubleTapPanned {
            self.tapped?(KanaFlickKey.Backspace, nil, withShift: false)
        }
        
        if gesture.state == UIGestureRecognizerState.Ended {
            KeyButtonFlickPopup.sharedInstance.hide()
            if key.sequence != nil || self.bounds.contains(p) {
                // always trigger when Seq, and trigger non-Seq (single char) key when touchUpInside
                self.tapped?(self.key, self.sequenceIndex, withShift: gesture === self.doubleTapPanGesture)
            }
            self.sequenceIndex = nil
            self.highlighted = false
            return
        }
        
        if self.bounds.contains(p) {
            self.sequenceIndex = (key.sequence != nil ? 0 : nil)
            KeyButtonFlickPopup.sharedInstance.hide()
            self.highlighted = true
        } else {
            self.highlighted = false
            if let s = key.sequence {
                let maxIndex = s.count - 1
                var direction = KeyButtonFlickDirection.None
                
                let angle = Double(atan2(p.y - self.bounds.height/2, p.x - self.bounds.width/2))
                if angle < -3*M_PI_4 || angle >= 3*M_PI_4 {
                    self.sequenceIndex = min(1, maxIndex)
                    direction = .Left
                } else if angle < -M_PI_4 {
                    self.sequenceIndex = min(2, maxIndex)
                    direction = .Up
                } else if angle < M_PI_4 {
                    self.sequenceIndex = min(3, maxIndex)
                    direction = .Right
                } else {
                    self.sequenceIndex = min(4, maxIndex)
                    direction = .Down
                }
                
                let text = String(Array(s)[self.sequenceIndex ?? 0])
                KeyButtonFlickPopup.sharedInstance.show(text, fromView: self, direction: direction)
            }
        }
    }

    // MARK: -
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
