import UIKit

// 追加辞書をダウンロードするURLを指定する画面。
class DictionaryURLViewController : SafeTableViewController, UITextFieldDelegate {
    private let urlField = UITextField(frame: CGRectZero)
    private lazy var doneButton : UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Download", comment:""),
        style: .Done, target:self, action: Selector("download"))
    private let done : String -> Void

    init(done : String -> Void) {
        self.done = done
        super.init(style: .Grouped)
        self.title = NSLocalizedString("Specify URL", comment: "")
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
            self.navigationController?.popViewControllerAnimated(true)
            self.done(self.urlField.text)
        }
    }
}
