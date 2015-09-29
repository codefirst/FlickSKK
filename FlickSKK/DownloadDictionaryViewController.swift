import UIKit

// URL指定で追加辞書のダウンロードを行なうための画面。
// ダウンロード処理自体は DownloadDictionary にまかせているので、画面表示だけを行なえばいい。
//
// プログレスバーでの進捗表示をしようかと思ったが、3G回線でもほぼ待ち時間なしでダウンロードできたので
// とりあえずあとまわしにしている。
class DownloadDictionaryViewController : SafeTableViewController, UITextFieldDelegate {
    private let urlField = UITextField(frame: CGRectZero)
    private lazy var doneButton : UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Download", comment:""),
        style: .Done, target:self, action: Selector("download"))
    private let done : Void -> Void

    init(url : String, done : Void -> Void) {
        self.done = done
        super.init(style: .Grouped)
        urlField.text = url
        self.doneButton.enabled = canDownload()
        self.navigationItem.rightBarButtonItem = doneButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: table view

    let kCellID = "Cell"

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)

        cell.textLabel?.text = NSLocalizedString("URL", comment:"")
        urlField.frame = CGRectMake(0, 0, cell.frame.width - 80, 130)
        urlField.clearButtonMode = .WhileEditing
        urlField.placeholder = "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei"
        urlField.contentVerticalAlignment = .Center
        urlField.delegate = self
        urlField.addTarget(self, action: "didChange", forControlEvents: .EditingChanged)
        cell.accessoryView = urlField
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        download()
        return true
    }

    // MARK: done button
    @objc private func didChange() {
        self.doneButton.enabled = canDownload()
    }

    private func canDownload() -> Bool {
        return !self.urlField.text.isEmpty
    }

    @objc private func download() {
        if canDownload() {
            let vc = HeadUpProgressViewController()
            let action = DownloadDictionary(url: self.urlField.text)

            var oldTitle : String? = nil
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
    }

    // アラートメッセージを表示する
    private func alert(title: String, message: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { _ in completion?() }))
        presentViewController(ac, animated: true, completion: nil)
    }
}
