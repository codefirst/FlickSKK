//
//  UserDictionaryViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

class UserDictionaryViewController: UITableViewController {
    fileprivate var entries : [SKKDictionaryEntry] = []

    init() {
        super.init(style: .grouped)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("User Dictionary", comment: "")

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(UserDictionaryViewController.openWordRegister))
        self.navigationItem.rightBarButtonItem = addButton

        self.reloadEntries()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    fileprivate func reloadEntries() {
        self.entries = SKKDictionary.defaultUserDictionary().entries()
        self.tableView.reloadData()
    }

    @objc func applicationDidBecomeActive(_ notification: Notification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // description + entries
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HowToRegisterWordToUserDictionary", comment: "")
        case 1: return NSString(format: NSLocalizedString("%d words registered", comment: "") as NSString, self.entries.count) as String
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return self.entries.count
        default: return 0
        }
    }

    fileprivate let kCellID = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID) ?? UITableViewCell(style: .default, reuseIdentifier: kCellID)
        cell.selectionStyle = .none

        switch self.entries[indexPath.row] {
        case .skkDictionaryEntry(kanji: let kanji, kana: let kana, okuri: let okuri):
            let o = okuri ?? ""
            cell.textLabel?.text = "\(kanji): \(kana)\(o)"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // TODO: something
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = self.entries[indexPath.row]
            SKKDictionary.defaultUserDictionary().unregister(entry)
            self.reloadEntries()
        }
    }

    // MARK: -
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func openWordRegister() {
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
