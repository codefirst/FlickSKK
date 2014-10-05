//
//  KeyButtonFlickPopup.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/05.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit



enum KeyButtonFlickDirection : Printable {
    case None, Left, Up, Right, Down
    
    var description: String {
        switch self {
        case .None: return "None"
        case .Left: return "←"
        case .Up: return "↑"
        case .Right: return "→"
        case .Down: return "↓"
        }
    }
}


class KeyButtonFlickPopup: UIView {
    // MARK: Singleton
    class var sharedInstance: KeyButtonFlickPopup {
        struct Static {
            static let instance = KeyButtonFlickPopup(frame: CGRectZero)
        }
        return Static.instance
    }
    // MARK: -
    
    weak var parentView: UIView? {
        didSet {
            if let v = parentView {
                v.addSubview(self)
            } else {
                removeFromSuperview()
            }
        }
    }
    
    let label = UILabel()
    var metrics: [String:CGFloat] {
        return ["p": 8,
            "popupExtendLength": 12]
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hue: 0.10, saturation: 0.07, brightness: 0.96, alpha: 1.0)
//        self.layer.borderColor = UIColor.redColor().CGColor
//        self.layer.borderWidth = 1.0
        self.clipsToBounds = false
        self.layer.cornerRadius = 2.0
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowRadius = 2.0
        
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(20.0)
        label.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.addSubview(label)
    }
    
    // MARK: - public methods
    func show(text: String, fromView: UIView, direction: KeyButtonFlickDirection) {
        if parentView == nil { return }
        let pv = parentView!
        pv.bringSubviewToFront(self)
        label.text = text
        
        var center = pv.convertPoint(fromView.center, fromView: fromView.superview)
        var size = fromView.bounds.size
        let extendLength: CGFloat = metrics["popupExtendLength"]!
        
        switch direction {
        case .None: break
        case .Left:
            center.x -= extendLength + size.width
            center.x = max(center.x, size.width / 2)
            size.height += extendLength * 2
        case .Up:
            center.y -= extendLength + size.height
            center.y = max(center.y, size.height / 2)
            size.width += extendLength * 3
        case .Right:
            center.x += extendLength + size.width
            center.x = min(center.x, pv.bounds.size.width - size.width / 2)
            size.height += extendLength * 2
        case .Down:
            center.y += extendLength + size.height
            center.y = min(center.y, pv.bounds.size.height - size.height / 2)
            size.width += extendLength * 3
        }
        
        self.frame = CGRectIntersection(CGRectMake(
            center.x - size.width / 2.0,
            center.y - size.height / 2.0,
            size.width,
            size.height), pv.bounds)
        self.label.frame = self.bounds
        
        self.hidden = (direction == .None)
    }
    
    func hide() {
        self.hidden = true
    }
    
    // MARK: - private methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
