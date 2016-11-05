import UIKit

// 追加辞書一覧を表示する画面。
// ダウンロード済みの辞書一覧の表示、削除、追加といったことをできるようにする。
//
// 辞書の更新は、URLをどこに保持するかが難しいので、現バージョンは対応しない。
class AdditionalDictionaryViewController: SafeTableViewController {
    fileprivate var entries : [AdditionalDictionaries.Entry] = []
    fileprivate var dictionaries : [AdditionalDictionaries.Entry] = []

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Additional Dictionary", comment: "")

        self.reloadEntries()

        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    // MARK: - Entries

    fileprivate func reloadEntries() {
        let action = AdditionalDictionaries()
        self.entries = action.enabledDictionaries()
        self.dictionaries = action.availableDictionaries()
        self.tableView.reloadData()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 2 // entries + quickadd
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return NSLocalizedString("AvailableDictionaries", comment: "")
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            if self.entries.isEmpty {
                return NSLocalizedString("No dictionaries", comment: "")
            } else {
                return NSString(format: NSLocalizedString("%d dictionaries is enabled", comment: "") as NSString, self.entries.count) as String
            }
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.entries.count
        case 1: return self.dictionaries.count
        default: return 0
        }
    }

    fileprivate let kCellID = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID) ?? UITableViewCell(style: .default, reuseIdentifier: kCellID)

        switch indexPath.section {
        case 0:
            cell.selectionStyle = .none
            cell.textLabel?.text = self.entries[indexPath.row].title
            cell.accessoryType = .none
        case 1:
            cell.textLabel?.text = self.dictionaries[indexPath.row].title
            cell.accessoryType = .disclosureIndicator
        default:
            fatalError("section > 2 has not been implemented")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 1:
            self.navigationController?.pushViewController(DownloadDictionaryViewController(url: dictionaries[indexPath.row].url,
                done: {
                    self.reloadEntries()
            }), animated: true)
        default:
            ()
        }
    }

    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if indexPath.section == 0 && editingStyle == .delete {
            if let local = self.entries[indexPath.row].local {
                let _ = try? FileManager.default.removeItem(at: local as URL)
                self.reloadEntries()
            }
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .delete
        } else {
            return .none
        }
    }
}
