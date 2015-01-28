//
//  CandidateListView
//  FlickSKK
//
//  Created by BAN Jun on 2015/01/26.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

import UIKit


private let kCellID = "CellID"


class CandidateListView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var candidates: [String] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var didSelectCandidateAtIndex: (Int -> Void)? = nil
    
    let collectionView: UICollectionView
    private let collectionViewLayout: UICollectionViewFlowLayout
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        self.collectionViewLayout = UICollectionViewFlowLayout().tap { (l: UICollectionViewFlowLayout) in
            l.scrollDirection = .Horizontal
            l.minimumInteritemSpacing = 0.0
            l.minimumLineSpacing = 0.0
        }
        self.collectionView = UICollectionView(
            frame: CGRect(origin: CGPointZero, size: frame.size),
            collectionViewLayout: self.collectionViewLayout).tap { (cv: UICollectionView) in
                cv.registerClass(CandidateCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
                cv.showsHorizontalScrollIndicator = false
                cv.showsVerticalScrollIndicator = false
                cv.backgroundColor = UIColor.whiteColor()
        }
        
        super.init(frame: frame)
        
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
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.didSelectCandidateAtIndex?(indexPath.row)
    }
    
    private func configureCell(cell: CandidateCollectionViewCell, forIndexPath indexPath: NSIndexPath) -> CandidateCollectionViewCell {
        let index = indexPath.item
        let candidate = (index < candidates.count) ? candidates[index] : "";
        cell.textLabel.text = candidate
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as CandidateCollectionViewCell
        return self.configureCell(cell, forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let minWidth = CGFloat(44 + 8)
        let cell = self.configureCell(CandidateCollectionViewCell(), forIndexPath: indexPath)
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
            l.font = UIFont.systemFontOfSize(17.0)
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
}
