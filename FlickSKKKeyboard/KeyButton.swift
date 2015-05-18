//
//  KeyButton.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/28.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation
import UIKit
import NorthLayout

let KeyButtonHighlightedColor = UIColor(hue: 0.10, saturation: 0.07, brightness: 0.96, alpha: 1.0)


class KeyButton: UIView, UIGestureRecognizerDelegate {
    let key: KanaFlickKey
    var sequenceIndex: Int? {
        didSet {
            if let s = key.sequence {
                let text = String(Array(s)[self.sequenceIndex ?? 0])
                // FIXME: special ignore label
                if(text != KanaFlickKey.ignoredSequence) {
                    self.label.text = text
                }
            }
        }
    }

    let label = UILabel()
    lazy var imageView: UIImageView = { [unowned self] in
        UIImageView().tap{ (iv:UIImageView) in
            self.label.text = nil

            iv.contentMode = .ScaleAspectFit

            let autolayout = self.northLayoutFormat(self.metrics, ["iv": iv])
            autolayout("H:|-p-[iv]-p-|")
            autolayout("V:|-p-[iv]-p-|")
        }
    }()
    lazy var sequenceLabel: UILabel = { [unowned self] in
        UILabel().tap { (l: UILabel) in
            l.text = self.key.additionalButtonLabel
            l.font = Appearance.normalFont(12)
            l.textColor = UIColor.lightGrayColor()
            l.textAlignment = .Center
        }
    }()
    var flicksEnabled: Bool = true

    var metrics: [String:CGFloat] {
        return ["p": 10]
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
    var highlighted: Bool {
        didSet {
            self.backgroundColor = highlighted ? KeyButtonHighlightedColor : selected ? selectedBackgroundColor : normalBackgroundColor
        }
    }

    var normalBackgroundColor: UIColor
    var selectedBackgroundColor: UIColor
    lazy var repeatTimer : KeyRepeatTimer? = {
        if self.key.isRepeat {
            return KeyRepeatTimer(delayInterval: 0.45, repeatInterval: 0.05, action: {
                self.tapped?(self.key, self.sequenceIndex)
                return ()
            })
        } else {
            return nil
        }
    }()

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
            l.font = Appearance.normalFont(17.0)
        }
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale / 2.0

        switch key {
        case .Seq(_, showSeqs: true):
            let autolayout = self.northLayoutFormat(metrics, ["label": label, "sequence": sequenceLabel])
            autolayout("H:|[label]|")
            autolayout("H:|[sequence]|")
            autolayout("V:[label]-2-[sequence]-2-|")
        default:
            let autolayout = self.northLayoutFormat(metrics, ["label": label])
            autolayout("H:|[label]|")
            autolayout("V:|[label]|")
        }

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "gestureTapped:"))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "gesturePanned:"))
    }

    // MARK: - Gestures
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.highlighted = true // set to false on end, cancel, started pan
        self.repeatTimer?.start()
        super.touchesBegan(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.highlighted = false
        self.repeatTimer?.cancel()
        super.touchesEnded(touches, withEvent: event)
    }

    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.highlighted = false // surpress flicker (highlighted = false, then true)
        self.repeatTimer?.cancel()
        super.touchesCancelled(touches, withEvent: event)
    }

    func gestureTapped(gesture: UITapGestureRecognizer) {
        KeyButtonFlickPopup.sharedInstance.hide()
        self.highlighted = false
        if !self.key.isRepeat {
            self.tapped?(self.key, self.sequenceIndex)
        }
    }

    var originOfPanGesture = CGPointZero

    func gesturePanned(gesture: UIPanGestureRecognizer) {
        // FIXME: キーリピート対応について、なにも考慮してない。
        // 動くような気もするけど未確認。
        let p = gesture.locationInView(self)

        if gesture.state == UIGestureRecognizerState.Began {
            originOfPanGesture = p
        }

        if gesture.state == UIGestureRecognizerState.Ended {
            let delay = 0.2 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                KeyButtonFlickPopup.sharedInstance.hide()
            })
            if key.sequence != nil || self.bounds.contains(p) {
                // always trigger when Seq, and trigger non-Seq (single char) key when touchUpInside
                self.tapped?(self.key, self.sequenceIndex)
            }
            self.sequenceIndex = nil
            self.highlighted = false
            return
        }

        if !flicksEnabled { return }

        let distance = sqrt(pow(p.x - originOfPanGesture.x, 2) + pow(p.y - originOfPanGesture.y, 2))
        if self.bounds.contains(p) && distance < 12 {
            self.sequenceIndex = (key.sequence != nil ? 0 : nil)
            KeyButtonFlickPopup.sharedInstance.hide()
            self.highlighted = true
        } else {
            self.highlighted = false
            if let s = key.sequence {
                let maxIndex = s.count - 1
                var direction = KeyButtonFlickDirection.None

                let angle = Double(atan2(p.y - originOfPanGesture.y, p.x - originOfPanGesture.x))
                if maxIndex >= 1 && (angle < -3*M_PI_4 || angle >= 3*M_PI_4) {
                    self.sequenceIndex = 1
                    direction = .Left
                } else if maxIndex >= 2 && angle < -M_PI_4 {
                    self.sequenceIndex = 2
                    direction = .Up
                } else if maxIndex >= 3 && angle < M_PI_4 {
                    self.sequenceIndex = 3
                    direction = .Right
                } else if maxIndex >= 4 {
                    self.sequenceIndex = 4
                    direction = .Down
                }

                if direction != .None {
                    let text = String(Array(s)[self.sequenceIndex ?? 0])
                    KeyButtonFlickPopup.sharedInstance.show(text, fromView: self, direction: direction)
                }
            }
        }
    }

    // MARK: -
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
