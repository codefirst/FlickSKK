import UIKit

// 追加辞書一覧を表示する画面。
// ダウンロード済みの辞書一覧の表示、削除、追加といったことをできるようにする。
//
// 辞書の更新は、URLをどこに保持するかが難しいので、現バージョンは対応しない。
class AdditionalDictionaryViewController: SafeTableViewController {
    private var entries : [String] = []

    private let dictionaries : [(title: String, url: String)] = [
        (title: "人名辞書", url: "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei"),
        (title: "沖縄辞書", url: "http://openlab.jp/skk/skk/dic/SKK-JISYO.okinawa"),
        (title: "その他(URL指定)", url: "")
    ]

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
        self.entries = SKKDictionary.additionalDictionaries()
         self.tableView.reloadData()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        self.reloadEntries()
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3 // entries + quickadd + link
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HowToAddDictionary", comment: "")
        case 1: return NSLocalizedString("UsefulDictionary", comment: "")
        case 2: return NSLocalizedString("LinkToOpenlab", comment: "")
        default: return nil
        }
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return NSString(format: NSLocalizedString("%d dictionaries registered", comment: ""), self.entries.count) as String
        default: return nil
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.entries.count
        case 1: return self.dictionaries.count
        case 2: return 1
        default: return 0
        }
    }

    private let kCellID = "Cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)

        switch indexPath.section {
        case 0:
            cell.selectionStyle = .None
            cell.textLabel?.text = self.entries[indexPath.row].lastPathComponent
        case 1:
            cell.textLabel?.text = self.dictionaries[indexPath.row].title
        case 2:
            cell.textLabel?.text = NSLocalizedString("OpenSKKDictWiki", comment: "")
        default:
            fatalError("section > 2 has not been implemented")
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath.section {
        case 1:
            self.navigationController?.pushViewController(DownloadDictionaryViewController(url: dictionaries[indexPath.row].url,
                done: {
                    self.reloadEntries()
            }), animated: true)
        case 2:
            UIApplication.sharedApplication().openURL(NSURL(string: "http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK%BC%AD%BD%F1")!)
        default:
            ()
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
}
