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
    let arrow = UIView()
    let arrowShapeLayer = CAShapeLayer()
    var metrics: [String:CGFloat] {
        return ["p": 8,
            "popupExtendLength": 12]
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = false
        self.layer.tap { (la:CALayer) in
            la.shadowColor = UIColor.blackColor().CGColor
            la.shadowOpacity = 0.2
            la.shadowOffset = CGSizeMake(0, 0)
            la.shadowRadius = 2.0
        }

        label.tap { (l:UILabel) in
            l.backgroundColor = KeyButtonHighlightedColor
            l.textColor = UIColor.blackColor()
            l.textAlignment = .Center
            l.font = UIFont.boldSystemFontOfSize(28.0)
            l.layer.tap { (la:CALayer) in
                la.cornerRadius = 2.0
                la.masksToBounds = true
            }
            self.addSubview(l)
        }

        arrowShapeLayer.tap{ (sl:CAShapeLayer) in
            sl.fillColor = KeyButtonHighlightedColor.CGColor
        }
        arrow.tap { (a:UIView) in
            a.backgroundColor = UIColor.clearColor()
            a.layer.addSublayer(self.arrowShapeLayer)
            self.addSubview(a)
        }
        userInteractionEnabled = false
    }

    // MARK: - public methods
    func show(text: String, fromView: UIView, direction: KeyButtonFlickDirection) {
        if parentView == nil { return }
        let pv = parentView!
        pv.bringSubviewToFront(self)
        label.text = text

        let center = pv.convertPoint(fromView.center, fromView: fromView.superview)
        var labelCenter = center
        var size = fromView.bounds.size
        let extendLength: CGFloat = metrics["popupExtendLength"]!

        var arrowFrameSize = CGSizeZero

        switch direction {
        case .None: break
        case .Left:
            labelCenter.x -= extendLength + size.width
            labelCenter.x = max(labelCenter.x, size.width / 2)
            size.height += extendLength * 2
            arrowFrameSize = CGSizeMake(2*(center.x - (labelCenter.x + size.width / 2)), size.height)
        case .Up:
            labelCenter.y -= extendLength + size.height
            labelCenter.y = max(labelCenter.y, size.height / 2)
            size.width += extendLength * 3
            arrowFrameSize = CGSizeMake(size.width, 2*(center.y - (labelCenter.y + size.height / 2)))
        case .Right:
            labelCenter.x += extendLength + size.width
            labelCenter.x = min(labelCenter.x, pv.bounds.size.width - size.width / 2)
            size.height += extendLength * 2
            arrowFrameSize = CGSizeMake(2*((labelCenter.x - size.width / 2) - center.x), size.height)
        case .Down:
            labelCenter.y += extendLength + size.height
            labelCenter.y = min(labelCenter.y, pv.bounds.size.height - size.height / 2)
            size.width += extendLength * 3
            arrowFrameSize = CGSizeMake(size.width, 2*((labelCenter.y - size.height / 2) - center.y))
        }

        let labelFrame = CGRectIntersection(CGRectMake(
            labelCenter.x - size.width / 2.0,
            labelCenter.y - size.height / 2.0,
            size.width,
            size.height), pv.bounds)
        let arrowFrame = CGRectIntersection(CGRectMake(
            center.x - arrowFrameSize.width / 2,
            center.y - arrowFrameSize.height / 2,
            arrowFrameSize.width,
            arrowFrameSize.height), pv.bounds)
        self.frame = CGRectUnion(labelFrame, arrowFrame)
        self.label.frame = self.convertRect(labelFrame, fromView: pv)
        self.arrow.frame = self.convertRect(arrowFrame, fromView: pv)

        arrowShapeLayer.path = UIBezierPath().tap{ (p:UIBezierPath) in
            let (c, lt, rt, lb, rb) = (
                self.arrow.convertPoint(center, fromView: pv),
                CGPointMake(0, 0),
                CGPointMake(arrowFrame.size.width, 0),
                CGPointMake(0, arrowFrame.size.height),
                CGPointMake(arrowFrame.size.width, arrowFrame.size.height))
            p.moveToPoint(c)
            switch direction {
            case .None: break
            case .Left:
                p.addLineToPoint(lt)
                p.addLineToPoint(lb)
            case .Up:
                p.addLineToPoint(lt)
                p.addLineToPoint(rt)
            case .Right:
                p.addLineToPoint(rt)
                p.addLineToPoint(rb)
            case .Down:
                p.addLineToPoint(lb)
                p.addLineToPoint(rb)
            }
            p.closePath()
        }.CGPath

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
