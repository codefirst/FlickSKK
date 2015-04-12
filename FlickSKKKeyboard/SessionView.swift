//
//  SessionView
//  FlickSKK
//
//  Created by BAN Jun on 2015/01/26.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

import UIKit


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
            
            dispatch_async(dispatch_get_main_queue()) {
                self.updateCandidateSelection()
            }
        }
    }
    var canEnterWordRegister = false
    var didSelectCandidateAtIndex: (Int -> Void)? = nil
    
    let collectionView: UICollectionView
    private let collectionViewLayout: UICollectionViewFlowLayout
    
    init(engine: SKKEngine) {
        self.engine = engine
        self.collectionViewLayout = UICollectionViewFlowLayout().tap { (l: UICollectionViewFlowLayout) in
            l.scrollDirection = .Horizontal
            l.minimumInteritemSpacing = 0.0
            l.minimumLineSpacing = 0.0
        }
        self.collectionView = UICollectionView(
            frame: CGRectZero,
            collectionViewLayout: self.collectionViewLayout).tap { (cv: UICollectionView) in
                cv.registerClass(CandidateCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
                cv.showsHorizontalScrollIndicator = false
                cv.showsVerticalScrollIndicator = false
                cv.backgroundColor = UIColor.whiteColor()
        }
        
        super.init(frame: CGRectZero)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
        
        let border = UIView().tap { (v: UIView) in
            v.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        }
        let autolayout = self.autolayoutFormat(
            ["onepx": 1.0 / UIScreen.mainScreen().scale],
            ["b": border])
        autolayout("H:|[b]|")
        autolayout("V:|[b(==onepx)]")
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCandidateSelection() {
        let selectionIndex = self.engine.candidates()?.index
        if let index = selectionIndex {
            if index < self.candidates.count {
                let indexPath = NSIndexPath(forItem: index, inSection: Section.Candidates.rawValue)
                if let la = collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
                    let visible = la.frame.width > 0 && CGRectIntersection(bounds, convertRect(la.frame, fromView: collectionView)).width == la.frame.width
                    let scrollPosition = visible ? .None : UICollectionViewScrollPosition.CenteredHorizontally
                    collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: scrollPosition)
                }
            }
        } else {
            // deselect all
            for indexPath in self.collectionView.indexPathsForSelectedItems() as! [NSIndexPath] {
                self.collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    
    enum Section: Int {
        case ComposeText = 0, Candidates, EnterWordRegister
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3 // composeText, candidates, EnterWordRegister
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .Some(.ComposeText): return self.composeText != nil ? 1 : 0
        case .Some(.Candidates): return self.candidates.count
        case .Some(.EnterWordRegister): return canEnterWordRegister ? 1 : 0
        case .None: return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .Some(.ComposeText): break
        case .Some(.Candidates): self.didSelectCandidateAtIndex?(indexPath.row)
        case .Some(.EnterWordRegister): self.didSelectCandidateAtIndex?(candidates.count)
        case .None: break
        }
    }
    
    private func configureCell(cell: CandidateCollectionViewCell, forIndexPath indexPath: NSIndexPath) -> CandidateCollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .Some(.ComposeText):
            cell.style = .Default
            cell.textLabel.text = self.composeText ?? ""
            cell.textLabel.textAlignment = .Left
            return cell
        case .Some(.Candidates):
            let candidate: Candidate? = (indexPath.item < candidates.count) ? candidates[indexPath.item] : nil
            cell.style = (candidate?.isPartial ?? false) ? .PartialCandidate : .Default
            cell.textLabel.text = candidate?.kanji
            cell.textLabel.textAlignment = .Center
            return cell
        case .Some(.EnterWordRegister):
            cell.style = .Default
            cell.textLabel.text = NSLocalizedString("EnterWordRegister", comment: "")
            cell.textLabel.textAlignment = .Center
            return cell
        case .None:
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as! CandidateCollectionViewCell
        return self.configureCell(cell, forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        struct Static { static let layoutCell = CandidateCollectionViewCell() }
        let minWidth = CGFloat(44 + 8)
        let cell = self.configureCell(Static.layoutCell, forIndexPath: indexPath)
        return CGSizeMake(max(cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).width, minWidth),self.collectionView.bounds.height)
    }
}


class CandidateCollectionViewCell: UICollectionViewCell {
    let textLabel = UILabel()
    
    enum Style {
        case Default, PartialCandidate
        
        var textColor: UIColor {
            switch self {
            case .Default: return UIColor.blackColor()
            case .PartialCandidate: return UIColor(white: 0.5, alpha: 1.0)
            }
        }
        var normalBackgroundColor: UIColor { return UIColor.whiteColor() }
        var highlightedBackgroundColor: UIColor { return UIColor(white: 0.5, alpha: 1.0) }
        var selectedBackgroundColor: UIColor { return UIColor(white: 0.9, alpha: 1.0) }
    }
    var style: Style = .Default {
        didSet {
            updateStates()
        }
    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.textLabel.tap { (l: UILabel) in
            l.font = Appearance.normalFont(17.0)
            l.backgroundColor = UIColor.clearColor()
            l.textAlignment = .Center
            l.lineBreakMode = .ByClipping
        }
        
        let border = UIView().tap { (v: UIView) in
            v.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        }
        
        let autolayout = self.autolayoutFormat(
            ["p": 4, "onepx": 1.0 / UIScreen.mainScreen().scale],
            ["l": self.textLabel, "b": border])
        autolayout("H:|[b(==onepx)]-p-[l]-p-|")
        autolayout("V:|[b]|")
        autolayout("V:|[l]|")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateStates() {
        UIView.setAnimationsEnabled(false) // disable fade-in
        self.backgroundColor = highlighted ? style.highlightedBackgroundColor
            : selected ? style.selectedBackgroundColor
            : style.normalBackgroundColor
        self.textLabel.textColor = style.textColor
        UIView.setAnimationsEnabled(true)
    }
    
    override var selected: Bool {
        didSet {
            self.updateStates()
        }
    }
    
    override var highlighted: Bool {
        didSet {
            self.updateStates()
        }
    }
}
