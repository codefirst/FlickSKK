//
//  KeyboardViewController.swift
//  FlickSKKKeyboard
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit


private var kGlobalDictionary: SKKDictionary?
private var kLoadedTime : NSDate? = nil

enum KanaFlickKey: Hashable {
    case Seq(String)
    case Shift
    case Return
    case Backspace
    case KeyboardChange
    case InputModeChange([SKKInputMode?])
    case Number
    case Alphabet
    case KomojiDakuten
    case UpperLower
    case Space
    case Nothing

    var buttonLabel: String {
        switch self {
        case let .Seq(s): return String(s[s.startIndex])
        case .Shift: return "⇧"
        case .Return: return "⏎"
        case .Backspace: return "⌫"
        case .KeyboardChange: return ""
        case .InputModeChange: return "かな"
        case .Number: return "123"
        case .Alphabet: return "ABC"
        case .KomojiDakuten: return "小゛゜"
        case .UpperLower: return "a/A"
        case .Space: return "space"
        case .Nothing: return ""
        }
    }

    var sequence: [String]? {
        switch self {
        case let .Seq(s): return Array(s).map({ (c : Character) -> String in return String(c)})
        case .InputModeChange: return ["-ignore-","_","かな","カナ","ｶﾅ"]
        default: return nil
        }
    }

    var isControl: Bool {
        switch self {
        case .Seq(_): return false
        default: return true
        }
    }

    var isRepeat: Bool {
        switch self {
        case .Backspace: return true
        default: return false
        }
    }

    var hashValue: Int {
        switch self {
        case .Seq(_): return 0
        case .Shift: return 1
        case .Return: return 2
        case .Backspace: return 3
        case KeyboardChange: return 4
        case .InputModeChange: return 5
        case .Number: return 6
        case .Alphabet: return 7
        case .KomojiDakuten: return 8
        case .UpperLower: return 9
        case .Space: return 10
        case .Nothing: return 11
        }
    }
}

func ==(l: KanaFlickKey, r: KanaFlickKey) -> Bool {
    switch (l, r) {
    case let (.Seq(ls), .Seq(rs)): return ls == rs
    default: return l.hashValue == r.hashValue
    }
}

enum KeyboardMode: Hashable {
    case InputMode(mode : SKKInputMode)
    case Number
    case Alphabet

    var hashValue: Int {
        switch self {
        case .InputMode(_): return 0
        case .Number: return 1
        case .Alphabet: return 2
        }
    }
}

func ==(l : KeyboardMode, r : KeyboardMode) -> Bool {
    switch (l,r)  {
    case let (.InputMode(m), .InputMode(n)): return m == n
    default: return l.hashValue == r.hashValue
    }
}

class KeyboardViewController: UIInputViewController, SKKDelegate, UITableViewDelegate {
    var heightConstraint : NSLayoutConstraint!

    let keypadAndControlsView = UIView()
    let contextView = UIView()
    let loadingProgressView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let sessionLabel = UILabel()
    let candidateView = UITableView()

    let nextKeyboardButton: KeyButton!
    let inputModeChangeButton : KeyButton!
    var numberModeButton : KeyButton!
    var alphabetModeButton : KeyButton!
    var inputProxy: UITextDocumentProxy {
        return self.textDocumentProxy as UITextDocumentProxy
    }

    let shiftButton: KeyButton!
    let keypads: [KeyboardMode:KeyPad]

    let session : SKKSession!
    let dataSource = CandidateDataSource()

    var shiftEnabled: Bool {
        didSet {
            updateControlButtons()
        }
    }
    var prevShiftEnabled: Bool = false

    var keyboardMode : KeyboardMode {
        didSet {
            updateControlButtons()
        }
    }

    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.keyboardMode = .InputMode(mode: .Hirakana)
        self.shiftEnabled = false
        self.keypads = [
            .InputMode(mode: .Hirakana): KeyPad(keys: [
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
            .InputMode(mode: .Katakana): KeyPad(keys: [
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
            .InputMode(mode: .HankakuKana): KeyPad(keys: [
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
            .Alphabet: KeyPad(keys: [
                .Seq("@#/&_"),
                .Seq("abc"),
                .Seq("def"),
                .Seq("ghi"),
                .Seq("jkl"),
                .Seq("mno"),
                .Seq("pqrs"),
                .Seq("tuv"),
                .Seq("wxyz"),
                .UpperLower,
                .Seq("'\"()"),
                .Seq(".,?!")
                ]),
        ]

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.nextKeyboardButton = keyButton(.KeyboardChange).tap { (kb:KeyButton) in
            kb.imageView.image = UIImage(named: "globe")
        }
        self.inputModeChangeButton = keyButton(.InputModeChange([nil, nil, .Hirakana, .Katakana, .HankakuKana]))
        self.numberModeButton = keyButton(.Number)
        self.alphabetModeButton = keyButton(.Alphabet)
        self.shiftButton = keyButton(.Shift).tap { (kb:KeyButton) in
            kb.imageView.image = UIImage(named: "flickskk-arrow")
        }

        for keypad in self.keypads.values {
            keypad.tapped = { [weak self] (key:KanaFlickKey, index:Int?) in
                self?.keyTapped(key, index)
                return
            }
        }
        loadDictionary()
        self.session = SKKSession(delegate: self, dict: kGlobalDictionary!)
        kGlobalDictionary!.addObserver(self, forKeyPath: SKKDictionary.isWaitingForLoadKVOKey(), options: NSKeyValueObservingOptions.allZeros, context: nil)
        updateControlButtons()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        kGlobalDictionary!.removeObserver(self, forKeyPath: SKKDictionary.isWaitingForLoadKVOKey())
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if let dict = object as? SKKDictionary {
            if dict.isWaitingForLoad {
                self.disableAllKeys()
                loadingProgressView.startAnimating()
            } else {
                self.enableAllKeys()
                loadingProgressView.stopAnimating()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    var metrics: [String:CGFloat] {
        return [:]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.heightConstraint = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 216)

        let leftControl = controlViewWithButtons([
            numberModeButton,
            alphabetModeButton,
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
        let cViews = [
            "progress": loadingProgressView,
            "l": sessionLabel,
        ]
        let autolayout = contextView.autolayoutFormat(metrics, cViews)
        autolayout("H:|[l][progress]-(>=0)-|")
        autolayout("V:|[progress]|")
        autolayout("V:|[l]|")

        candidateView.dataSource = dataSource
        candidateView.delegate = self
        candidateView.hidden = true

        updateControlButtons()

        KeyButtonFlickPopup.sharedInstance.parentView = inputView

        sessionLabel.text = AppGroup.initialText()

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

    private func loadDictionary() {
        let userDict = SKKUserDictionaryFile.defaultUserDictionaryPath()
        let mtime = getModifiedTime(userDict)

        if kGlobalDictionary == nil || kLoadedTime != mtime {
            let dict = NSBundle.mainBundle().pathForResource("skk", ofType: "jisyo")
            kGlobalDictionary = SKKDictionary(userDict: userDict, dicts: [dict!])
            kLoadedTime = mtime
        }
    }

    private func getModifiedTime(path: String) -> NSDate? {
        let fm = NSFileManager.defaultManager()
        if let attrs = fm.attributesOfItemAtPath(path, error: nil) {
            return attrs[NSFileModificationDate] as NSDate
        } else {
            return nil
        }
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
            self.session.handle(.Char(kana: String(kana), roman: roman, shift: self.shiftEnabled))
            self.prevShiftEnabled = self.shiftEnabled
            self.shiftEnabled = false
        case .Backspace:
            self.session.handle(.Backspace)
            self.shiftEnabled = self.prevShiftEnabled
            self.prevShiftEnabled = false
        case .Return:
            self.session.handle(.Enter)
        case .Shift: toggleShift()
        case .KeyboardChange:
            advanceToNextInputMode()
        case .InputModeChange(let modes):
            switch modes[index ?? 0] {
            case .Some(let m):
                self.session.handle(.InputModeChange(inputMode: m))
            case .None:
                ()
            }
            self.keyboardMode = .InputMode(mode: self.session.currentMode)
        case .Number:
            self.keyboardMode = .Number
        case .Alphabet:
            self.keyboardMode = .Alphabet
        case .KomojiDakuten: self.toggleKomojiDakuten()
        case .UpperLower: self.toggleUpperLower()
        case .Space: self.handleSpace()
        case .Nothing: break
        }
        updateControlButtons()
    }

    func updateControlButtons() {
        // Keyboard mode
        for (mode, keypad) in self.keypads {
            keypad.hidden = !(mode == keyboardMode)
        }

        // each button
        switch(self.keyboardMode) {
        case .InputMode(_):
            self.inputModeChangeButton.selected = true
        default:
            self.inputModeChangeButton.selected = false
        }
        self.numberModeButton.selected = self.keyboardMode == .Number
        self.alphabetModeButton.selected = self.keyboardMode == .Alphabet
        self.shiftButton.selected = self.shiftEnabled

        // InputMode
        switch self.session.currentMode {
        case .Hirakana:
            self.inputModeChangeButton.label.text = "かな"
        case .Katakana:
            self.inputModeChangeButton.label.text = "カナ"
        case .HankakuKana:
            self.inputModeChangeButton.label.text = "ｶﾅ"
        }
    }

    func toggleShift() {
        self.shiftEnabled = !self.shiftEnabled
    }

    func handleSpace() {
        session.handle(.Space)
    }

    func toggleKomojiDakuten() {
        self.session.handle(.ToggleDakuten(beforeText: self.inputProxy.documentContextBeforeInput ?? ""))
    }

    func toggleUpperLower() {
        self.session.handle(.ToggleUpperLower(beforeText: self.inputProxy.documentContextBeforeInput ?? ""))
    }

    func composeText(text: String) {
        sessionLabel.text = text
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

    private let userInteractionMaskView = UIView()
    private func disableAllKeys() {
        userInteractionMaskView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        userInteractionMaskView.frame = self.view.bounds
        userInteractionMaskView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        if userInteractionMaskView.superview == nil {
            self.view.addSubview(userInteractionMaskView)
        } else {
            self.view.bringSubviewToFront(userInteractionMaskView)
        }
    }
    private func enableAllKeys() {
        userInteractionMaskView.removeFromSuperview()
    }

    func deleteBackward() {
        (self.textDocumentProxy as UIKeyInput).deleteBackward()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 24
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.session.handle(.SelectCandidate(index: indexPath.row))
    }
}
