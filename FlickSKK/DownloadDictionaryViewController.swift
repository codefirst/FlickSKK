import UIKit

// URL指定で追加辞書のダウンロードを行なうための画面。
// ダウンロード処理自体は DownloadDictionary にまかせているので、画面表示だけを行なえばいい。
//
// プログレスバーでの進捗表示をしようかと思ったが、3G回線でもほぼ待ち時間なしでダウンロードできたので
// とりあえずあとまわしにしている。
class DownloadDictionaryViewController : SafeTableViewController, UITextFieldDelegate {
    fileprivate let urlField = UITextField(frame: CGRect.zero)
    fileprivate lazy var doneButton : UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Download", comment:""),
        style: .done, target:self, action: #selector(DownloadDictionaryViewController.download))
    fileprivate let done : (Void) -> Void

    init(url : URL?, done : @escaping (Void) -> Void) {
        self.done = done
        super.init(style: .grouped)
        urlField.text = url?.absoluteString ?? ""
        self.doneButton.isEnabled = canDownload()
        self.navigationItem.rightBarButtonItem = doneButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: table view

    let kCellID = "Cell"

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID) ?? UITableViewCell(style: .default, reuseIdentifier: kCellID)

        cell.textLabel?.text = NSLocalizedString("URL", comment:"")
        urlField.frame = CGRect(x: 0, y: 0, width: cell.frame.width - 80, height: 130)
        urlField.clearButtonMode = .whileEditing
        urlField.placeholder = "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei"
        urlField.contentVerticalAlignment = .center
        urlField.delegate = self
        urlField.addTarget(self, action: #selector(DownloadDictionaryViewController.didChange as (DownloadDictionaryViewController) -> () -> ()), for: .editingChanged)
        cell.accessoryView = urlField
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        download()
        return true
    }

    // MARK: done button
    @objc fileprivate func didChange() {
        self.doneButton.isEnabled = canDownload()
    }

    fileprivate func canDownload() -> Bool {
        return self.urlField.text?.isEmpty == false
    }

    @objc fileprivate func download() {
        if canDownload() {
            guard let url = self.urlField.text.flatMap({ URL(string: $0)}) else { return }

            let vc = HeadUpProgressViewController()
            let action = DownloadDictionary(url: url)

            action.progress = { (title, progress) in
                vc.text = title
                vc.progress = progress
            }
            action.success = { info in
                vc.close {
                    self.alert(NSLocalizedString("DownloadComplete", comment:""),
                        message: NSString(format: NSLocalizedString("%d okuri-ari %d okuri-nasi", comment:"") as NSString, info.okuriAri(), info.okuriNasi()) as String) {
                            let _ = self.navigationController?.popViewController(animated: true)
                            self.done()
                    }
                }
            }
            action.error = { (title, e) in
                vc.close {
                    self.alert(title, message: e.map { String(describing: $0) } ?? "" )
                }
            }
            action.call()
            present(vc, animated: true, completion: nil)
        }
    }

    // アラートメッセージを表示する
    fileprivate func alert(_ title: String, message: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in completion?() }))
        present(ac, animated: true, completion: nil)
    }
}
