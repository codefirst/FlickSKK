//
//  CandidateListView
//  FlickSKK
//
//  Created by BAN Jun on 2015/01/26.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

import UIKit


private let kCellID = "CellID"


class CandidateListView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
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
            l.itemSize = CGSizeZero
            l.minimumInteritemSpacing = 1.0 / UIScreen.mainScreen().scale // inter-item border width
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionViewLayout.itemSize = CGSizeMake(64, self.bounds.height)
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.didSelectCandidateAtIndex?(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let candidate = (index < candidates.count) ? candidates[index] : "";
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as CandidateCollectionViewCell
        
        cell.textLabel.text = candidate
        
        return cell
    }
}


class CandidateCollectionViewCell: UICollectionViewCell {
    let textLabel = UILabel()
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        self.textLabel.tap { (l: UILabel) in
            l.font = UIFont.systemFontOfSize(17.0)
            l.textColor = UIColor.blackColor()
            l.backgroundColor = UIColor.whiteColor()
            l.textAlignment = .Center
            l.lineBreakMode = .ByClipping
            l.adjustsFontSizeToFitWidth = true
        }
        
        let autolayout = self.autolayoutFormat(["p": 2], ["l": self.textLabel])
        autolayout("H:|-p-[l]-p-|")
        autolayout("V:|[l]|")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
