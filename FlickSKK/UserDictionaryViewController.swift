//
//  UserDictionaryViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit
import FlickSKKKeyboard

class UserDictionaryViewController: UITableViewController {
    let userDict = SKKUserDictionaryFile.defaultUserDictionary()
    
    convenience override init() {
        self.init(style: .Grouped)
    }
    
    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("User Dictionary", comment: "")
    }
    
    // MARK: - Table View
    
    private func dictForSection(section: Int) -> NSMutableDictionary? {
        switch section {
        case 0: return userDict.okuriAri
        case 1: return userDict.okuriNasi
        default: return nil
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("Okuri-Ari", comment: "")
        case 1: return NSLocalizedString("Okuri-Nashi", comment: "")
        default: return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictForSection(section)?.count ?? 0
    }
    
    private let kCellID = "Cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)
        
        if let dict = dictForSection(indexPath.section) {
            let key = dict.allKeys[indexPath.row] as String
            let value = dict[key]! as String
            
            cell.textLabel.text = "\(key): \(value)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // TODO: something
    }

    // MARK: -
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
