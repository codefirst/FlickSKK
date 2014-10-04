//
//  KeyboardViewController.swift
//  FlickSKKKeyboard
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

enum KanaFlickKey: Hashable {
    case Seq(String)
    case Shift
    case Return
    case Backspace
    case InputModeChange([SKKInputMode?])
    case Number
    case KomojiDakuten
    case Space
    case Nothing
    
    var buttonLabel: String {
        switch self {
        case let .Seq(s): return String(s[s.startIndex])
        case .Shift: return "⇧"
        case .Return: return "⏎"
        case .Backspace: return "⌫"
        case .InputModeChange: return "あ"
        case .Number: return "123"
        case .KomojiDakuten: return "小゛゜"
        case .Space: return "space"
        case .Nothing: return ""
        }
    }
    
    var sequence: [String]? {
        switch self {
        case let .Seq(s): return Array(s).map({ (c : Character) -> String in return String(c)})
        case .InputModeChange: return ["-ignore-","_","あ","ア","ｶﾅ"]
        default: return nil
        }
    }
    
    var isControl: Bool {
        switch self {
        case .Seq(_): return false
        default: return true
        }
    }
    
    var hashValue: Int {
        switch self {
        case .Seq(_): return 0
        case .Shift: return 1
        case .Return: return 2
        case .Backspace: return 3
        case .InputModeChange: return 4
        case .Number: return 5
        case .KomojiDakuten: return 6
        case .Space: return 7
        case .Nothing: return 8
        }
    }
}

func ==(l: KanaFlickKey, r: KanaFlickKey) -> Bool {
    switch (l, r) {
    case let (.Seq(ls), .Seq(rs)): return ls == rs
    default: return l.hashValue == r.hashValue
    }
}


enum KeyboardMode {
    case Hirakana
    case Katakana
    case HankakuKana
    case Number
}


private func newKeyboardGlobeButton(target: UIInputViewController) -> UIButton {
    return (UIButton.buttonWithType(.System) as UIButton).tap {
        (b:UIButton) in
        b.setTitle(NSLocalizedString("🌐", comment: "globe"), forState: .Normal)
        b.addTarget(target, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        b.backgroundColor = UIColor.lightGrayColor()
        b.layer.borderColor = UIColor.grayColor().CGColor
        b.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale / 2.0
    }
}


class KeyboardViewController: UIInputViewController, SKKDelegate, UITableViewDelegate {
    var heightConstraint : NSLayoutConstraint!
    
    let keypadAndControlsView = UIView()
    let contextView = UILabel()
    let candidateView = UITableView()
    
    let nextKeyboardButton: UIButton!
    let inputModeChangeButton : KeyButton!
    var inputProxy: UITextDocumentProxy {
        return self.textDocumentProxy as UITextDocumentProxy
    }
    
    let shiftButton: KeyButton!
    let keypads: [KeyboardMode:KeyPad]
    
    let session : SKKSession?
    let dataSource = CandidateDataSource()
    
    var shiftEnabled: Bool {
        didSet {
            updateControlButtons()
        }
    }
    var keyboardMode: KeyboardMode {
        didSet {
            updateControlButtons()
        }
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.shiftEnabled = false
        self.keyboardMode = .Hirakana
        self.keypads = [
            .Hirakana: KeyPad(keys: [
                .Seq("あいうえお"),
                .Seq("かきくけこ"),
                .Seq("さしすせそ"),
                .Seq("たちつてと"),
                .Seq("なにぬねの"),
                .Seq("はひふへほ"),
                .Seq("まみむめも"),
                .Seq("や「ゆ」よ"),
                .Seq("らりるれろ"),
                .KomojiDakuten,
                .Seq("わをんー"),
                .Seq("、。？！"),
                ]),
            .Katakana: KeyPad(keys: [
                .Seq("アイウエオ"),
                .Seq("カキクケコ"),
                .Seq("サシスセソ"),
                .Seq("タチツテト"),
                .Seq("ナニヌネノ"),
                .Seq("ハヒフヘホ"),
                .Seq("マミムメモ"),
                .Seq("ヤ「ユ」ヨ"),
                .Seq("ラリルレロ"),
                .KomojiDakuten,
                .Seq("ワヲンー"),
                .Seq("、。？！"),
                ]),
            .HankakuKana: KeyPad(keys: [
                .Seq("ｱｲｳｴｵ"),
                .Seq("ｶｷｸｹｺ"),
                .Seq("ｻｼｽｾｿ"),
                .Seq("ﾀﾁﾂﾃﾄ"),
                .Seq("ﾅﾆﾇﾈﾉ"),
                .Seq("ﾊﾋﾌﾍﾎ"),
                .Seq("ﾏﾐﾑﾒﾓ"),
                .Seq("ﾔ「ﾕ」ﾖ"),
                .Seq("ﾗﾘﾙﾚﾛ"),
                .KomojiDakuten,
                .Seq("ﾜｦﾝ-"),
                .Seq("、。？！"),
                ]),
            .Number: KeyPad(keys: [
                .Seq("1"),
                .Seq("2"),
                .Seq("3"),
                .Seq("4"),
                .Seq("5"),
                .Seq("6"),
                .Seq("7"),
                .Seq("8"),
                .Seq("9"),
                .Seq("()[]"),
                .Seq("0～⋯"),
                .Seq(".,-/"),
                ]),
        ]
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.nextKeyboardButton = newKeyboardGlobeButton(self)
        self.inputModeChangeButton = keyButton(.InputModeChange([nil, nil, .Hirakana, .Katakana, .HankakuKana]))
        self.shiftButton = keyButton(.Shift)
        
        for keypad in self.keypads.values {
            keypad.tapped = { [weak self] (key:KanaFlickKey, index:Int?) in
                self?.keyTapped(key, index)
                return
            }
        }

        let userDict = NSHomeDirectory().stringByAppendingPathComponent("Library/skk.jisyo")
        if !NSFileManager.defaultManager().fileExistsAtPath(userDict) {
            NSFileManager.defaultManager().createFileAtPath(userDict, contents: nil, attributes:nil)
        }
        NSLog("%@\n", userDict)
        let dict = NSBundle.mainBundle().pathForResource("skk", ofType: "jisyo")
//        self.session = SKKSession(delegate: self, dict: SKKDictionary(userDict: userDict, dicts: [dict!]))
        
        updateInputMode()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var metrics: [String:CGFloat] {
        return [:]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.heightConstraint = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 216)
        
        let leftControl = controlViewWithButtons([
            keyButton(.Number),
            keyButton(.Nothing), // FIXME: some button
            inputModeChangeButton,
            nextKeyboardButton,
            ])
        let rightControl = controlViewWithButtons([
            keyButton(.Backspace),
            keyButton(.Space),
            self.shiftButton,
            keyButton(.Return),
            ])
        
        for keypad in self.keypads.values {
            let views = [
                "left": leftControl,
                "right": rightControl,
                "keypad": keypad,
            ]
            var autolayout = self.keypadAndControlsView.autolayoutFormat(metrics, views)
            autolayout("H:|[left][keypad][right(==left)]|")
            autolayout("V:|[left]|")
            autolayout("V:|[keypad]|")
            autolayout("V:|[right]|")
            self.keypadAndControlsView.addConstraint(NSLayoutConstraint(item: keypad, attribute: .Width, relatedBy: .Equal, toItem: leftControl, attribute: .Width, multiplier: 3.0, constant: 0.0))
        }
        
        contextView.backgroundColor = UIColor.whiteColor()
        contextView.text = "welcome to SKK"
        
        candidateView.dataSource = dataSource
        candidateView.delegate = self
        candidateView.hidden = true
        
        updateControlButtons()
        
        // iOS8 layout height(0) workaround: call self.inputView.addSubview() after viewDidAppear
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupViewConstraints() // iOS8 layout height(0) workaround: setup constraints after view did appear
        // keyboard height can be changed, but cause some layout errors.
        // 'UIView-Encapsulated-Layout-Height' V:[UIInputView:...(216)]
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//            self.heightConstraint.constant += 100
//        }
    }
    
    private func setupViewConstraints() {
        if CGRectIsEmpty(view.frame) {
            println("\(__FUNCTION__): empty view. ignored.")
            return
        }
        
        if contextView.isDescendantOfView(view) {
            return
        }
        
        let views = [
            "context": contextView,
            "candidate" : candidateView,
            "keypadAndControls": keypadAndControlsView,
        ]
        let autolayout = self.inputView.autolayoutFormat(metrics, views)
        autolayout("H:|[context]|")
        autolayout("H:|[keypadAndControls]|")
        autolayout("H:|[candidate]|")
        autolayout("V:|[context(==30)]")
        autolayout("V:|[context][keypadAndControls]|")
        autolayout("V:|[context][candidate]|")
        self.view.addConstraint(heightConstraint);
    }
    
    func controlViewWithButtons(buttons: [UIView]) -> UIView {
        if (buttons.count != 4) { println("fatal: cannot add buttons not having 4 buttons to control"); return UIView(); }
        
        let views = [
            "a": buttons[0],
            "b": buttons[1],
            "c": buttons[2],
            "d": buttons[3],
        ]
        
        return UIView().tap { (c:UIView) in
            let autolayout = c.autolayoutFormat(self.metrics, views)
            autolayout("H:|[a]|")
            autolayout("H:|[b]|")
            autolayout("H:|[c]|")
            autolayout("H:|[d]|")
            autolayout("V:|[a][b(==a)][c(==a)][d(==a)]|")
        }
    }

    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
        
        updateControlButtons()
    }
    
    private func keyButton(key: KanaFlickKey) -> KeyButton {
        return KeyButton(key: key).tap { (b:KeyButton) in
            weak var weakSelf = self
            b.tapped = { (key:KanaFlickKey, index:Int?) in
                weakSelf?.keyTapped(key, index)
                return
            }
        }
    }
    
    func insertText(s: String) {
        self.inputProxy.insertText(s)
        self.shiftEnabled = false
        self.updateControlButtons()
    }
    
    func keyTapped(key: KanaFlickKey, _ index: Int?) {
        switch key {
        case let .Seq(s):
            let kana = Array(s)[index ?? 0]
            let roman = kana.toRoman() ?? ""
            self.session?.handle(.Char(kana: String(kana), roman: roman), shift: self.shiftEnabled)
            self.shiftEnabled = false
        case .Backspace:
            self.session?.handle(.Backspace, shift: self.shiftEnabled)
        case .Return:
            self.session?.handle(.Enter, shift: self.shiftEnabled)
        case .Shift: toggleShift()
        case .InputModeChange(let modes):
            switch modes[index ?? 0] {
            case .Some(let m):
                self.session?.handle(.InputModeChange(inputMode: m), shift: self.shiftEnabled)
            case .None:
                ()
            }
        case .Number: self.keyboardMode = .Number
        case .KomojiDakuten: self.toggleKomojiDakuten()
        case .Space: self.handleSpace()
        case .Nothing: break
        }
        updateInputMode()
    }
    
    func updateControlButtons() {
        for (mode, keypad) in self.keypads {
            keypad.hidden = !(mode == self.keyboardMode)
        }
        
        self.shiftButton.selected = self.shiftEnabled
        
        // default implementation
        self.nextKeyboardButton.setTitleColor(inputProxy.keyboardAppearance == UIKeyboardAppearance.Dark ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
    }
    
    func toggleShift() {
        self.shiftEnabled = !self.shiftEnabled
    }
    
    func handleSpace() {
        session?.handle(.Space, shift: self.shiftEnabled)
    }
    
    func toggleKomojiDakuten() {
        self.session?.handle(.ToggleDakuten, shift: self.shiftEnabled)
    }
    
    func composeText(text: String) {
        contextView.text = text
    }
    
    func showCandidates(candidates: [String]?) {
        switch candidates {
        case .Some(let xs):
            dataSource.update(xs)
            candidateView.reloadData()
            keypadAndControlsView.hidden = true
            candidateView.hidden = false
        case .None:
            keypadAndControlsView.hidden = false
            candidateView.hidden = true
        }
    }
    
    func updateInputMode() {
        if self.session == nil { return }
        switch self.session!.currentMode {
        case .Hirakana:
            self.inputModeChangeButton.label.text = "あ"
            self.keyboardMode = .Hirakana
        case .Katakana:
            self.inputModeChangeButton.label.text = "ア"
            self.keyboardMode = .Katakana
        case .HankakuKana:
            self.inputModeChangeButton.label.text = "ｶﾅ"
            self.keyboardMode = .HankakuKana
        }
        updateControlButtons()
    }
    
    func deleteBackward() {
        (self.textDocumentProxy as UIKeyInput).deleteBackward()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 24
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.session?.handle(.SelectCandidate(index: indexPath.row), shift: self.shiftEnabled)
    }
    
    func beforeString() -> String {
        return self.inputProxy.documentContextBeforeInput
    }
}
