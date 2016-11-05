//
//  ViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

class MainMenuViewController: SafeTableViewController {
    typealias row = (title: String, accessoryType: UITableViewCellAccessoryType, action: (Void) -> Void)
    lazy var sections : [(title: String?, rows: [row])] = {
        weak var weakSelf = self
        return [
            (title: nil, rows: [
                self.item("Setup") { weakSelf?.gotoSetup() },
                self.item("How to use") { weakSelf?.gotoHowToUse() }]),
            (title: nil, rows: [
                self.item("User Dictionary") { weakSelf?.gotoUserDictionary() },
                self.item("Additional Dictionary") { weakSelf?.gotoAdditionalDictionary() }]),
            (title: nil, rows: [self.item("Reset Learn Dictionary", accessoryType: .none) {
                weakSelf?.reset(); return
            }]),
            (title: nil, rows: [self.item("License") {
                weakSelf?.gotoLicense()
            }])
        ]
    }()

    init() {
        super.init(style: .grouped)
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("FlickSKK", comment: "")
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    let kCellID = "Cell"

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID) ?? UITableViewCell(style: .default, reuseIdentifier: kCellID)
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.accessoryType = row.accessoryType
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section].rows[indexPath.row]
        row.action()
    }

    fileprivate func item(_ title : String, accessoryType: UITableViewCellAccessoryType = .disclosureIndicator, action : @escaping (Void) -> Void) -> row {
        return (title: NSLocalizedString(title, comment: ""), accessoryType: accessoryType, action: action)
    }

    // MARK: - Actions
    func gotoSetup() {
        if let path = Bundle.main.path(forResource: "Setup", ofType: "html", inDirectory: "html") {
            navigationController?.pushViewController(WebViewController(URL: URL(fileURLWithPath: path)), animated: true)
        }
    }


    func gotoHowToUse() {
        if let path = Bundle.main.path(forResource: "HowToUse", ofType: "html", inDirectory: "html") {
            navigationController?.pushViewController(WebViewController(URL: URL(fileURLWithPath: path)), animated: true)
        }
    }

    func gotoSettings() {

    }

    func gotoAdditionalDictionary() {
        navigationController?.pushViewController(AdditionalDictionaryViewController(), animated: true)
    }

    func gotoUserDictionary() {
        navigationController?.pushViewController(UserDictionaryViewController(), animated: true)
    }

    func reset() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reset", comment: ""), style: .destructive, handler: { action in
            SKKDictionary.resetLearnDictionary()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func gotoLicense() {
        if let path = Bundle.main.path(forResource: "License", ofType: "html", inDirectory: "html") {
            navigationController?.pushViewController(WebViewController(URL: URL(fileURLWithPath: path)), animated: true)
        }
    }

    // MARK: -

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

