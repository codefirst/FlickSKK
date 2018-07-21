//
//  KeyButtonFlickPopup.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/05.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit
import Ikemen


enum KeyButtonFlickDirection : CustomStringConvertible {
    case none, left, up, right, down

    var description: String {
        switch self {
        case .none: return "None"
        case .left: return "←"
        case .up: return "↑"
        case .right: return "→"
        case .down: return "↓"
        }
    }
}


class KeyButtonFlickPopup: UIView {
    // MARK: Singleton
    static let sharedInstance: KeyButtonFlickPopup = KeyButtonFlickPopup(frame: CGRect.zero)

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

    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = false
        _ = self.layer ※ { (la:inout CALayer) in
            la.shadowColor = UIColor.black.cgColor
            la.shadowOpacity = 0.2
            la.shadowOffset = CGSize(width: 0, height: 0)
            la.shadowRadius = 2.0
        }

        _ = label ※ { (l:inout UILabel) in
            l.backgroundColor = KeyButtonHighlightedColor
            l.textColor = UIColor.black
            l.textAlignment = .center
            l.font = Appearance.boldFont(28.0)
            l.adjustsFontSizeToFitWidth = true
            l.baselineAdjustment = .alignCenters
            _ = l.layer ※ { (la:inout CALayer) in
                la.cornerRadius = 2.0
                la.masksToBounds = true
            }
            self.addSubview(l)
        }

        _ = arrowShapeLayer ※ { (sl:inout CAShapeLayer) in
            sl.fillColor = KeyButtonHighlightedColor.cgColor
        }
        _ = arrow ※ { (a:inout UIView) in
            a.backgroundColor = UIColor.clear
            a.layer.addSublayer(self.arrowShapeLayer)
            self.addSubview(a)
        }
        isUserInteractionEnabled = false
    }

    // MARK: - public methods
    func show(_ text: String, fromView: UIView, direction: KeyButtonFlickDirection) {
        if parentView == nil { return }
        let pv = parentView!
        pv.bringSubview(toFront: self)
        label.text = text

        let center = pv.convert(fromView.center, from: fromView.superview)
        var labelCenter = center
        var size = fromView.bounds.size
        let extendLength: CGFloat = metrics["popupExtendLength"]!

        var arrowFrameSize = CGSize.zero

        switch direction {
        case .none: break
        case .left:
            labelCenter.x -= extendLength + size.width
            labelCenter.x = max(labelCenter.x, size.width / 2)
            size.height += extendLength * 2
            arrowFrameSize = CGSize(width: 2*(center.x - (labelCenter.x + size.width / 2)), height: size.height)
        case .up:
            labelCenter.y -= extendLength + size.height
            labelCenter.y = max(labelCenter.y, size.height / 2)
            size.width += extendLength * 3
            arrowFrameSize = CGSize(width: size.width, height: 2*(center.y - (labelCenter.y + size.height / 2)))
        case .right:
            labelCenter.x += extendLength + size.width
            labelCenter.x = min(labelCenter.x, pv.bounds.size.width - size.width / 2)
            size.height += extendLength * 2
            arrowFrameSize = CGSize(width: 2*((labelCenter.x - size.width / 2) - center.x), height: size.height)
        case .down:
            labelCenter.y += extendLength + size.height
            labelCenter.y = min(labelCenter.y, pv.bounds.size.height - size.height / 2)
            size.width += extendLength * 3
            arrowFrameSize = CGSize(width: size.width, height: 2*((labelCenter.y - size.height / 2) - center.y))
        }

        let labelFrame = CGRect(
            x: labelCenter.x - size.width / 2.0,
            y: labelCenter.y - size.height / 2.0,
            width: size.width,
            height: size.height).intersection(pv.bounds)
        let arrowFrame = CGRect(
            x: center.x - arrowFrameSize.width / 2,
            y: center.y - arrowFrameSize.height / 2,
            width: arrowFrameSize.width,
            height: arrowFrameSize.height).intersection(pv.bounds)
        self.frame = labelFrame.union(arrowFrame)
        self.label.frame = self.convert(labelFrame, from: pv)
        self.arrow.frame = self.convert(arrowFrame, from: pv)

        arrowShapeLayer.path = (UIBezierPath() ※ { (p: inout UIBezierPath) in
            let (c, lt, rt, lb, rb) = (
                self.arrow.convert(center, from: pv),
                CGPoint(x: 0, y: 0),
                CGPoint(x: arrowFrame.size.width, y: 0),
                CGPoint(x: 0, y: arrowFrame.size.height),
                CGPoint(x: arrowFrame.size.width, y: arrowFrame.size.height))
            p.move(to: c)
            switch direction {
            case .none: break
            case .left:
                p.addLine(to: lt)
                p.addLine(to: lb)
            case .up:
                p.addLine(to: lt)
                p.addLine(to: rt)
            case .right:
                p.addLine(to: rt)
                p.addLine(to: rb)
            case .down:
                p.addLine(to: lb)
                p.addLine(to: rb)
            }
            p.close()
        }).cgPath

        self.isHidden = (direction == .none)
    }

    func hide() {
        self.isHidden = true
    }

    // MARK: - private methods
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
