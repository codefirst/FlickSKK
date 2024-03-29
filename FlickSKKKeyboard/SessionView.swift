//
//  SessionView
//  FlickSKK
//
//  Created by BAN Jun on 2015/01/26.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

import UIKit
import NorthLayout
import Ikemen

private let kCellID = "CellID"


class SessionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let engine: SKKEngine
    var composeText: String? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var candidates: [Candidate] = [] {
        didSet {
            self.collectionView.reloadData()

            DispatchQueue.main.async {
                self.updateCandidateSelection()
            }
        }
    }
    var canEnterWordRegister = false
    var didSelectCandidateAtIndex: ((Int) -> Void)? = nil

    let collectionView: UICollectionView
    fileprivate let collectionViewLayout: UICollectionViewFlowLayout

    init(engine: SKKEngine) {
        self.engine = engine
        self.collectionViewLayout = UICollectionViewFlowLayout() ※ { (l: inout UICollectionViewFlowLayout) in
            l.scrollDirection = .horizontal
            l.minimumInteritemSpacing = 0.0
            l.minimumLineSpacing = 0.0
        }
        self.collectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: self.collectionViewLayout) ※ { (cv: inout UICollectionView) in
                cv.register(CandidateCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
                cv.showsHorizontalScrollIndicator = false
                cv.showsVerticalScrollIndicator = false
                cv.backgroundColor = ThemeColor.keyboardBackground
        }

        super.init(frame: CGRect.zero)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)

        let border = UIView() ※ { (v: inout UIView) in
            v.backgroundColor = ThemeColor.sessionCellBorder
        }
        let autolayout = self.northLayoutFormat(
            ["onepx": 1.0 / UIScreen.main.scale],
            ["b": border])
        autolayout("H:|[b]|")
        autolayout("V:|[b(==onepx)]")

        self.backgroundColor = ThemeColor.keyboardBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateCandidateSelection() {
        let selectionIndex = self.engine.candidates()?.index
        if let index = selectionIndex {
            if index < self.candidates.count {
                let indexPath = IndexPath(item: index, section: Section.candidates.rawValue)
                if let la = collectionViewLayout.layoutAttributesForItem(at: indexPath) {
                    let visible = la.frame.width > 0 && bounds.intersection(convert(la.frame, from: collectionView)).width == la.frame.width
                    let scrollPosition = visible ? UICollectionView.ScrollPosition() : UICollectionView.ScrollPosition.centeredHorizontally
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: scrollPosition)
                }
            }
        } else {
            // deselect all
            for indexPath in self.collectionView.indexPathsForSelectedItems ?? [] {
                self.collectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }

    // MARK: UICollectionViewDataSource, UICollectionViewDelegate

    enum Section: Int {
        case composeText = 0, candidates, enterWordRegister
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // composeText, candidates, EnterWordRegister
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.composeText): return self.composeText != nil ? 1 : 0
        case .some(.candidates): return self.candidates.count
        case .some(.enterWordRegister): return canEnterWordRegister ? 1 : 0
        case .none: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .some(.composeText): break
        case .some(.candidates): self.didSelectCandidateAtIndex?(indexPath.row)
        case .some(.enterWordRegister): self.didSelectCandidateAtIndex?(candidates.count)
        case .none: break
        }
    }

    fileprivate func configureCell(_ cell: CandidateCollectionViewCell, forIndexPath indexPath: IndexPath) -> CandidateCollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.composeText):
            cell.style = .default
            cell.textLabel.text = self.composeText ?? ""
            cell.textLabel.textAlignment = .left
            return cell
        case .some(.candidates):
            let candidate: Candidate? = (indexPath.item < candidates.count) ? candidates[indexPath.item] : nil
            cell.style = (candidate?.isPartial ?? false) ? .partialCandidate : .default
            cell.textLabel.text = candidate?.kanji
            cell.textLabel.textAlignment = .center
            return cell
        case .some(.enterWordRegister):
            cell.style = .default
            cell.textLabel.text = NSLocalizedString("EnterWordRegister", comment: "")
            cell.textLabel.textAlignment = .center
            return cell
        case .none:
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath) as! CandidateCollectionViewCell
        return self.configureCell(cell, forIndexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        struct Static { static let layoutCell = CandidateCollectionViewCell() }

        let minWidth: CGFloat
        switch Section(rawValue: indexPath.section) {
        case .composeText?: minWidth = 8 + 8
        case .candidates?, .enterWordRegister?, nil: minWidth = 44 + 8
        }

        let cell = self.configureCell(Static.layoutCell, forIndexPath: indexPath)
        return CGSize(width: max(cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width, minWidth),height: self.collectionView.bounds.height)
    }
}


class CandidateCollectionViewCell: UICollectionViewCell {
    let textLabel = UILabel()

    enum Style {
        case `default`, partialCandidate

        var textAlpha: CGFloat {
            switch self {
            case .default: return 1.0
            case .partialCandidate: return 0.5
            }
        }
    }
    var style: Style = .default {
        didSet {
            updateStates()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = ThemeColor.keyboardBackground

        _ = self.textLabel ※ { (l: inout UILabel) in
            l.font = Appearance.normalFont(17.0)
            l.textColor = ThemeColor.buttonText
            l.backgroundColor = UIColor.clear
            l.textAlignment = .center
            l.lineBreakMode = .byClipping
        }

        let border = UIView() ※ { (v: inout UIView) in
            v.backgroundColor = ThemeColor.sessionCellBorder
        }

        let autolayout = self.northLayoutFormat(
            ["p": 4, "onepx": 1.0 / UIScreen.main.scale],
            ["l": self.textLabel, "b": border])
        autolayout("H:|[b(==onepx)]-p-[l]-p-|")
        autolayout("V:|[b]|")
        autolayout("V:|[l]|")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateStates() {
        UIView.setAnimationsEnabled(false) // disable fade-in
        self.backgroundColor = isHighlighted ? ThemeColor.highlightedBackground
            : isSelected ? ThemeColor.selectedBackground
            : ThemeColor.keyboardBackground
        textLabel.alpha = style.textAlpha
        UIView.setAnimationsEnabled(true)
    }

    override var isSelected: Bool {
        didSet {
            self.updateStates()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.updateStates()
        }
    }
}
