//
//  SettingsViewController.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 12/18/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

import UIKit
class WordRegisterViewController : UITableViewController, UITextFieldDelegate {
    fileprivate let yomiField = UITextField(frame: CGRect.zero)
    fileprivate let okuriField = UITextField(frame: CGRect.zero)
    fileprivate let wordField = UITextField(frame: CGRect.zero)
    fileprivate lazy var doneButton : UIBarButtonItem =
        UIBarButtonItem(title: NSLocalizedString("Register", comment:""),
            style: .done, target:self, action: #selector(WordRegisterViewController.register))
    var done : ((String, String?, String) -> Void)?

    fileprivate lazy var sections : [(
        title: String?,
        rows: [(title: String, text: UITextField, returnType: UIReturnKeyType)]
    )] = [
        (title: nil, rows: [
            (title: NSLocalizedString("word", comment: ""), text: self.wordField, returnType: .next),
            (title: NSLocalizedString("yomi", comment: ""), text: self.yomiField, returnType: .next),
            (title: NSLocalizedString("okuri", comment: ""), text: self.okuriField, returnType: .default),
    ])]

    init() {
        super.init(style: .grouped)
        self.doneButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = doneButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func register() {
        if canRegister() {
            var okuri : String? = nil

            if let text = self.okuriField.text, !text.isEmpty {
                // 1文字目
                let xs = Array(text)
                let first = xs[0]
                // ローマ字変換
                if let roman = first.toRoman() {
                    // 1文字目を取得
                    let rs = Array(roman)
                    okuri = String(rs[0])
                } else {
                    okuri = String(first)
                }
            }
            self.done?(
                self.wordField.text ?? "",
                okuri,
                self.yomiField.text ?? "")
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    let kCellID = "Cell"

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID) ?? UITableViewCell(style: .default, reuseIdentifier: kCellID)

        let row = sections[indexPath.section].rows[indexPath.row]
        cell.accessoryType = .none
        cell.selectionStyle = .none

        // label
        let label = UILabel(frame: CGRect(x: 20, y: 5, width: 130, height: 45))
        label.text = row.title
        label.font = Appearance.normalFont(17.0)
        cell.contentView.addSubview(label)

        // text field
        let textField = row.text
        textField.frame = CGRect(x: 130, y: 0, width: view.frame.width-130, height: 50)
        textField.font = Appearance.normalFont(17.0)
        textField.clearButtonMode = .whileEditing
        textField.placeholder = row.title
        textField.contentVerticalAlignment = .center
        textField.returnKeyType = row.returnType
        textField.delegate = self
        textField.addTarget(self, action: #selector(didChange(sender:)), for: .editingChanged)
        cell.contentView.addSubview(textField)

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for section in self.sections {
            for (index,row) in section.rows.enumerated() {
                if textField == row.text {
                    switch row.returnType {
                    case .next:
                        section.rows[index+1].text.becomeFirstResponder()
                    case .default:
                        register()
                    default:
                        // do nothing
                        break
                    }
                }
            }
        }
        return true
    }

    @objc fileprivate func didChange(sender: UITextField) {
        self.doneButton.isEnabled = canRegister()
    }

    fileprivate func canRegister() -> Bool {
        // 登録できる条件
        // ・登録する単語が入力されている
        // ・よみが入力されている。SKK的に読みはほぼ任意(例: forallとかもある)なので、あまり前提をおけない。
        // ・送り仮名が空もしくはひらがな一文字(ローマ字に変換できる)
        let wordInputed : Bool = !(self.wordField.text?.isEmpty ?? true)
        let yomiInputed : Bool = !(yomiField.text?.isEmpty ?? true)

        let okuriBlank : Bool = self.okuriField.text?.isEmpty ?? true
        let okuri = self.okuriField.text
        let okuriInputed = okuri?.count == 1 && (okuri?.first?.toRoman() != nil)

        return wordInputed && yomiInputed && (okuriBlank || okuriInputed)
    }
}
