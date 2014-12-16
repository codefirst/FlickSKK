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
    var entries : [SKKDictionaryEntry] = []

    convenience override init() {
        self.init(style: .Grouped)
    }

    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("User Dictionary", comment: "")
        self.reloadEntries()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    private func reloadEntries() {
        self.entries = SKKUserDictionaryFile.defaultUserDictionary().entries()
        self.tableView.reloadData()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // description + entries
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HowToRegisterWordToUserDictionary", comment: "")
        case 1: return NSString(format: NSLocalizedString("%d words registered", comment: ""), self.entries.count)
        default: return nil
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return self.entries.count
        default: return 0
        }
    }

    private let kCellID = "Cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)
        cell.selectionStyle = .None

        switch self.entries[indexPath.row] {
        case .SKKDictionaryEntry(kanji: let kanji, kana: let kana, okuri: let okuri):
            let o = okuri ?? ""
            cell.textLabel?.text = "\(kanji): \(kana)\(o)"
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // TODO: something
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let entry = self.entries[indexPath.row]
            SKKUserDictionaryFile.defaultUserDictionary().unregister(entry)
            self.reloadEntries()
        }
    }

    // MARK: -
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
