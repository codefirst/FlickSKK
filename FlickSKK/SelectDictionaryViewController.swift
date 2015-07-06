import UIKit

// 追加できる辞書一覧を表示して、ダウンロードする辞書を選ばせる画面。
// URLを直接指定することもある。
class SelectDictionaryViewController: SafeTableViewController {
    private let done : Void -> Void

    private lazy var entries = AdditionalDictionaries().availableDictionaries()

    init(done : Void -> Void) {
        self.done = done
        super.init(style: .Grouped)
        self.title =  NSLocalizedString("Add New Dictionary", comment: "")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // entries + add
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return ""
        case 1: return NSLocalizedString("Other Dictionary", comment: "")
        default: fatalError("section > 1 has not been implemented")
        }
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

        cell.selectionStyle = .None

        switch indexPath.section {
        case 0: cell.textLabel?.text = self.entries[indexPath.row].title
        case 1:
            cell.textLabel?.text = NSLocalizedString("Specify URL", comment: "")
            cell.accessoryType = .DisclosureIndicator
        default: ()
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath.section {
        case 0:
            self.download(self.entries[indexPath.row].url)
        case 1:
            self.navigationController?.pushViewController(DictionaryURLViewController(            done: { url in
                    self.download(url)
            }), animated: true)
        default:
            ()
        }
    }

    // MARK: - Download
    private func download(url : String) {
        let vc = HeadUpProgressViewController()
        let action = DownloadDictionary(url: url)

        action.progress = { (title, progress) in
            vc.text = title
            vc.progress = progress
        }
        action.success = { info in
            vc.close {
                self.alert(NSLocalizedString("DownloadComplete", comment:""),
                    message: NSString(format: NSLocalizedString("%d okuri-ari %d okuri-nasi", comment:""), info.okuriAri(), info.okuriNasi()) as String) {
                        self.navigationController?.popViewControllerAnimated(true)
                        self.done()
                }
            }
        }
        action.error = { (title, e) in
            vc.close {
                self.alert(title, message: e?.localizedDescription ?? "")
            }
        }
        action.call()
        presentViewController(vc, animated: true, completion: nil)
    }

    // アラートメッセージを表示する
    private func alert(title: String, message: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { _ in completion?() }))
        presentViewController(ac, animated: true, completion: nil)
    }
}