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

        _ = label ※ { (l:inout UILabel) in
            l.backgroundColor = ThemeColor.buttonHighlighted
            l.textColor = ThemeColor.buttonTextOnFlickPopup
            l.textAlignment = .center
            l.font = Appearance.boldFont(28.0)
            l.adjustsFontSizeToFitWidth = true
            l.baselineAdjustment = .alignCenters
            _ = l.layer ※ { (la:inout CALayer) in
                la.cornerRadius = 4
                la.masksToBounds = true
            }
            self.addSubview(l)
        }

        _ = arrow ※ { (a:inout UIView) in
            a.backgroundColor = UIColor.clear
            a.layer.addSublayer(self.arrowShapeLayer)
            self.addSubview(a)
        }
        isUserInteractionEnabled = false

        updateCGColor()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCGColor()
    }

    private func updateCGColor() {
        clipsToBounds = false
        layer.shadowColor = ThemeColor.shadow.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 2.0

        arrowShapeLayer.fillColor = ThemeColor.buttonHighlighted.cgColor
    }

    // MARK: - public methods
    func show(_ text: String, fromView: UIView, direction: KeyButtonFlickDirection) {
        if parentView == nil { return }
        let pv = parentView!
        pv.bringSubviewToFront(self)
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
            let r = label.layer.cornerRadius

            func tangentPointToCorner(cornerCenterToKeyCenter offset: CGPoint, leftSelector: (CGPoint, CGPoint) -> Bool) -> CGPoint {
                let r2 = r * r
                let c1 = CGPoint(x: c.x - offset.x, y: c.y - offset.y)
                let c2 = CGPoint(x: c1.x * c1.x, y: c1.y * c1.y)
                let s1 = CGPoint(
                    x: Double((c1.x * r2 + c1.y * r * sqrt(c2.x + c2.y - r2)) / (c2.x + c2.y)),
                    y: Double((c1.y * r2 - c1.x * r * sqrt(c2.x + c2.y - r2)) / (c2.x + c2.y)))
                let s2 = CGPoint(
                    x: Double((c1.x * r2 - c1.y * r * sqrt(c2.x + c2.y - r2)) / (c2.x + c2.y)),
                    y: Double((c1.y * r2 + c1.x * r * sqrt(c2.x + c2.y - r2)) / (c2.x + c2.y)))
                return leftSelector(s1, s2) ? s1 : s2
            }

            p.move(to: c)
            switch direction {
            case .none: break
            case .left:
                let ltOffset = CGPoint(x: lt.x - r, y: lt.y + r)
                let s = tangentPointToCorner(cornerCenterToKeyCenter: ltOffset) {$0.y < $1.y}
                p.addLine(to: CGPoint(x: ltOffset.x + s.x, y: ltOffset.y + s.y))

                let lbOffset = CGPoint(x: lb.x - r, y: lb.y - r)
                let t = tangentPointToCorner(cornerCenterToKeyCenter: lbOffset) {$0.y > $1.y}
                p.addLine(to: CGPoint(x: lbOffset.x + t.x, y: lbOffset.y + t.y))
            case .up:
                let ltOffset = CGPoint(x: lt.x + r, y: lt.y - r)
                let s = tangentPointToCorner(cornerCenterToKeyCenter: ltOffset) {$0.x < $1.x}
                p.addLine(to: CGPoint(x: ltOffset.x + s.x, y: ltOffset.y + s.y))

                let rtOffset = CGPoint(x: rt.x - r, y: rt.y - r)
                let t = tangentPointToCorner(cornerCenterToKeyCenter: rtOffset) {$0.x > $1.x}
                p.addLine(to: CGPoint(x: rtOffset.x + t.x, y: rtOffset.y + t.y))
            case .right:
                let rtOffset = CGPoint(x: rt.x + r, y: rt.y + r)
                let s = tangentPointToCorner(cornerCenterToKeyCenter: rtOffset) {$0.y < $1.y}
                p.addLine(to: CGPoint(x: rtOffset.x + s.x, y: rtOffset.y + s.y))

                let rbOffset = CGPoint(x: rb.x + r, y: rb.y - r)
                let t = tangentPointToCorner(cornerCenterToKeyCenter: rbOffset) {$0.y > $1.y}
                p.addLine(to: CGPoint(x: rbOffset.x + t.x, y: rbOffset.y + t.y))
            case .down:
                let lbOffset = CGPoint(x: lb.x + r, y: lb.y + r)
                let s = tangentPointToCorner(cornerCenterToKeyCenter: lbOffset) {$0.x < $1.x}
                p.addLine(to: CGPoint(x: lbOffset.x + s.x, y: lbOffset.y + s.y))

                let rbOffset = CGPoint(x: rb.x - r, y: rb.y + r)
                let t = tangentPointToCorner(cornerCenterToKeyCenter: rbOffset) {$0.x > $1.x}
                p.addLine(to: CGPoint(x: rbOffset.x + t.x, y: rbOffset.y + t.y))
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
