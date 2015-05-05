import UIKit

// 追加辞書一覧を表示する画面。
// ダウンロード済みの辞書一覧の表示、削除、追加といったことをできるようにする。
//
// 辞書の更新は、URLをどこに保持するかが難しいので、現バージョンは対応しない。
class AdditionalDictionaryViewController: SafeTableViewController {
    private var entries : [String] = []

    init() {
        super.init(style: .Grouped)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Additional Dictionary", comment: "")

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("add"))
        self.navigationItem.rightBarButtonItem = addButton

        self.reloadEntries()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    // MARK: - Entries

    private func reloadEntries() {
        self.entries = SKKDictionary.additionalDictionaries()
         self.tableView.reloadData()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // entries + link
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HowToAddDictionary", comment: "")
        default: return nil
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.entries.count
        case 1: return 1
        default: return 0
        }
    }

    private let kCellID = "Cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)

        if indexPath.section == 0 {
            cell.selectionStyle = .None
            cell.textLabel?.text = self.entries[indexPath.row].lastPathComponent
        } else {
            cell.textLabel?.text = NSLocalizedString("OpenSKKDictWiki", comment: "")
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 1 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK%BC%AD%BD%F1")!)
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && editingStyle == .Delete {
            let path = self.entries[indexPath.row]
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            self.reloadEntries()
        }
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else {
            return .None
        }
    }

    // MARK: -
    @objc private func add() {
        self.navigationController?.pushViewController(DownloadDictionaryViewController(done: {
            self.reloadEntries()
        }), animated: true)
    }
}
