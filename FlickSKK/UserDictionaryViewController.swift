//
//  UserDictionaryViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit
import FlickSKKKeyboard

class UserDictionaryViewController: SafeTableViewController {
    private var entries : [SKKDictionaryEntry] = []

    init() {
        super.init(style: .Grouped)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("User Dictionary", comment: "")

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("openWordRegister"))
        self.navigationItem.rightBarButtonItem = addButton

        self.reloadEntries()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    private func reloadEntries() {
        self.entries = SKKDictionary.defaultUserDictionary().entries()
        self.tableView.reloadData()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // description + entries
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HowToRegisterWordToUserDictionary", comment: "")
        case 1: return NSString(format: NSLocalizedString("%d words registered", comment: ""), self.entries.count) as String
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // TODO: something
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let entry = self.entries[indexPath.row]
            SKKDictionary.defaultUserDictionary().unregister(entry)
            self.reloadEntries()
        }
    }

    // MARK: -
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func openWordRegister() {
        let controller = WordRegisterViewController()
        controller.done = {(word, okuri, yomi) in
            let dict = SKKDictionary.defaultUserDictionary()
            dict.register(yomi, okuri: okuri, kanji: word)
            dict.serialize()
            self.reloadEntries()
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
