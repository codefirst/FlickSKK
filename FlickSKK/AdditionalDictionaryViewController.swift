import UIKit

// 追加辞書一覧を表示する画面。
// ダウンロード済みの辞書一覧の表示、削除、追加といったことをできるようにする。
//
// 辞書の更新は、URLをどこに保持するかが難しいので、現バージョンは対応しない。
class AdditionalDictionaryViewController: SafeTableViewController {
    private var entries : [AdditionalDictionaries.Entry] = []

    init() {
        super.init(style: .Grouped)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Additional Dictionary", comment: "")

        self.reloadEntries()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    // MARK: - Entries

    private func reloadEntries() {
        self.entries = AdditionalDictionaries().enabledDictionaries()
         self.tableView.reloadData()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // entries + add
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.entries.count
        case 1: return 1
        default: fatalError("section > 1 has not been implemented")
        }
    }

    private let kCellID = "Cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)

        switch indexPath.section {
        case 0:
            cell.selectionStyle = .None
            cell.textLabel?.text = self.entries[indexPath.row].title
        case 1:
            cell.textLabel?.text = NSLocalizedString("Add New Dictionary", comment: "")
            cell.accessoryType = .DisclosureIndicator
        default:
            fatalError("section > 1 has not been implemented")
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath.section {
        case 1:
            self.navigationController?.pushViewController(SelectDictionaryViewController(             done: {
                    self.reloadEntries()
            }), animated: true)
        default:
            ()
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && editingStyle == .Delete {
            if let path = self.entries[indexPath.row].path {
                NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            }
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
}
