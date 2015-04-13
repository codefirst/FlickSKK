//
//  ViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

class MainMenuViewController: SafeTableViewController {
    typealias row = (title: String, accessoryType: UITableViewCellAccessoryType, action: Void -> Void)
    var sections : [(title: String?, rows: [row])]!

    init() {
        super.init(style: .Grouped)

        weak var weakSelf = self
        sections = [
            (title: nil, rows: [item("Setup", action: { weakSelf?.gotoSetup(); return})]),
            (title: nil, rows: [item("How to use", action: { weakSelf?.gotoHowToUse(); return})]),
            // FIXME: 設定項目をなんか増やす
            // (title: nil, rows: [(title: NSLocalizedString("Settings", comment: ""), action: { weakSelf?.gotoSettings(); return})]),
            (title: nil, rows: [item("User Dictionary", action: { weakSelf?.gotoUserDictionary(); return})]),
            (title: nil, rows: [item("Reset Learn Dictionary", accessoryType: .None, action: { weakSelf?.reset(); return})]),
            (title: nil, rows: [item("License", action: { weakSelf?.gotoLicense(); return})])
        ]
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("FlickSKK", comment: "")
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    let kCellID = "Cell"

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.accessoryType = row.accessoryType
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = sections[indexPath.section].rows[indexPath.row]
        row.action()
    }

    private func item(title : String, accessoryType: UITableViewCellAccessoryType = .DisclosureIndicator, action : Void -> Void) -> row {
        return (title: NSLocalizedString(title, comment: ""), accessoryType: accessoryType, action: action)
    }

    // MARK: - Actions
    func gotoSetup() {
        if let path = NSBundle.mainBundle().pathForResource("Setup", ofType: "html", inDirectory: "html") {
            navigationController?.pushViewController(WebViewController(URL: NSURL(fileURLWithPath: path)!), animated: true)
        }
    }


    func gotoHowToUse() {
        if let path = NSBundle.mainBundle().pathForResource("HowToUse", ofType: "html", inDirectory: "html") {
            navigationController?.pushViewController(WebViewController(URL: NSURL(fileURLWithPath: path)!), animated: true)
        }
    }

    func gotoSettings() {

    }

    func gotoUserDictionary() {
        navigationController?.pushViewController(UserDictionaryViewController(), animated: true)
    }

    func reset() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reset", comment: ""), style: .Destructive, handler: { action in
            SKKDictionary.resetLearnDictionary()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func gotoLicense() {
        if let path = NSBundle.mainBundle().pathForResource("License", ofType: "html", inDirectory: "html") {
            navigationController?.pushViewController(WebViewController(URL: NSURL(fileURLWithPath: path)!), animated: true)
        }
    }

    // MARK: -

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

