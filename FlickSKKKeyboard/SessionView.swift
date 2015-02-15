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
    var candidates: [String] = [] {
        didSet {
            self.collectionView.reloadData()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.updateCandidateSelection()
            }
        }
    }
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
                let scrollPosition = contains(self.collectionView.indexPathsForVisibleItems() as [NSIndexPath], indexPath) ? UICollectionViewScrollPosition.CenteredHorizontally : .None
                self.collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: scrollPosition)
            }
        } else {
            // deselect all
            for indexPath in self.collectionView.indexPathsForSelectedItems() as [NSIndexPath] {
                self.collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    
    enum Section: Int {
        case ComposeText = 0, Candidates
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2 // composeText, candidates
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .Some(.ComposeText): return self.composeText != nil ? 1 : 0
        case .Some(.Candidates): return self.candidates.count
        case .None: return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .Some(.ComposeText): break
        case .Some(.Candidates): self.didSelectCandidateAtIndex?(indexPath.row)
        case .None: break
        }
    }
    
    private func configureCell(cell: CandidateCollectionViewCell, forIndexPath indexPath: NSIndexPath) -> CandidateCollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .Some(.ComposeText):
            cell.textLabel.text = self.composeText ?? ""
            cell.textLabel.textAlignment = .Left
            return cell
        case .Some(.Candidates):
            let index = indexPath.item
            let candidate = (index < candidates.count) ? candidates[index] : "";
            cell.textLabel.text = candidate
            cell.textLabel.textAlignment = .Center
            return cell
        case .None:
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as CandidateCollectionViewCell
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
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.textLabel.tap { (l: UILabel) in
            l.font = Appearance.normalFont(17.0)
            l.textColor = UIColor.blackColor()
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
        self.backgroundColor = highlighted ? UIColor(white: 0.5, alpha: 1.0)
            : selected ? UIColor(white: 0.9, alpha: 1.0)
            : UIColor.whiteColor()
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
