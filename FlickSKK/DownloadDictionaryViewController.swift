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

    init() {
        super.init(style: .Grouped)
        urlField.text = "http://openlab.jp/skk/skk/dic/SKK-JISYO.okinawa"
        self.doneButton.enabled = canDownload()
        self.navigationItem.rightBarButtonItem = doneButton
    }

    required init(coder aDecoder: NSCoder) {
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
        cell.accessoryView = makeTextField(urlField)
        return cell
    }

    private func makeTextField(textField : UITextField) -> UITextField {
        textField.frame = CGRectMake(0, 0, 250, 130)
        textField.font = Appearance.normalFont(14.0)
        textField.clearButtonMode = .WhileEditing
        textField.placeholder = "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei"
        textField.contentVerticalAlignment = .Center
        textField.delegate = self
        textField.addTarget(self, action: "didChange", forControlEvents: .EditingChanged)
        return textField
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
            let action = DownloadDictionary(url: self.urlField.text)

            action.success = {
                self.navigationController?.popViewControllerAnimated(true)
            }
            action.error = { e in
                let alert = UIAlertView()
                alert.title = NSLocalizedString("DownloadError", comment:"")
                alert.message = "\(e.localizedDescription): \(e.userInfo?.description)"
                alert.addButtonWithTitle("Ok")
                alert.show()
            }

            action.call()
        }
    }
}
