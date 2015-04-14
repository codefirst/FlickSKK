//
//  KeyboardViewController.swift
//  FlickSKKKeyboard
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, SKKDelegate {
    lazy var heightConstraint : NSLayoutConstraint =
        NSLayoutConstraint(item: self.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 216)

    let keypadAndControlsView = UIView()
    let loadingProgressView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    lazy var sessionView : SessionView =
        SessionView(engine: self.engine)

    var inputProxy: UITextDocumentProxy {
        return self.textDocumentProxy as! UITextDocumentProxy
    }

    // MARK: Status
    var inputMode : SKKInputMode = .Hirakana

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

    // MARK: SKK
    lazy var engine : SKKEngine =
        SKKEngine(delegate: self, dictionary: self.dictionary)

    lazy var dictionary : SKKDictionary =
        SKKDictionary()

    // MARK: Keypads
    let keypads: [KeyboardMode:KeyPad]

    // MARK: Buttons
    lazy var nextKeyboardButton : KeyButton =
        self.keyButton(.KeyboardChange).tap { (kb:KeyButton) in
            kb.imageView.image = UIImage(named: "globe")
        }

    lazy var inputModeChangeButton : KeyButton =
        self.keyButton(.InputModeChange([nil, nil, .Hirakana, .Katakana, .HankakuKana]))

    lazy var numberModeButton : KeyButton =
        self.keyButton(.Number)

    lazy var alphabetModeButton : KeyButton =
        self.keyButton(.Alphabet)

    lazy var spaceButton : KeyButton =
        self.keyButton(.Space)

    lazy var shiftButton: KeyButton =
        self.keyButton(.Shift).tap { (kb:KeyButton) in
            kb.imageView.image = UIImage(named: "flickskk-arrow")
        }

    // MARK: -

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.keyboardMode = .InputMode(mode: .Hirakana)
        self.shiftEnabled = false
        let seq = {(s: String) -> KanaFlickKey in .Seq(s, showSeqs: false)}
        let seqWithSymbols = {(s: String) -> KanaFlickKey in .Seq(s, showSeqs: true)}
        self.keypads = [
            .InputMode(mode: .Hirakana): KeyPad(keys: [
                seq("あいうえお"),
                seq("かきくけこ"),
                seq("さしすせそ"),
                seq("たちつてと"),
                seq("なにぬねの"),
                seq("はひふへほ"),
                seq("まみむめも"),
                seq("や「ゆ」よ"),
                seq("らりるれろ"),
                .KomojiDakuten,
                seq("わをんー"),
                seqWithSymbols("、。？！"),
                ]),
            .InputMode(mode: .Katakana): KeyPad(keys: [
                seq("アイウエオ"),
                seq("カキクケコ"),
                seq("サシスセソ"),
                seq("タチツテト"),
                seq("ナニヌネノ"),
                seq("ハヒフヘホ"),
                seq("マミムメモ"),
                seq("ヤ「ユ」ヨ"),
                seq("ラリルレロ"),
                .KomojiDakuten,
                seq("ワヲンー"),
                seqWithSymbols("、。？！"),
                ]),
            .InputMode(mode: .HankakuKana): KeyPad(keys: [
                seq("ｱｲｳｴｵ"),
                seq("ｶｷｸｹｺ"),
                seq("ｻｼｽｾｿ"),
                seq("ﾀﾁﾂﾃﾄ"),
                seq("ﾅﾆﾇﾈﾉ"),
                seq("ﾊﾋﾌﾍﾎ"),
                seq("ﾏﾐﾑﾒﾓ"),
                seq("ﾔ「ﾕ」ﾖ"),
                seq("ﾗﾘﾙﾚﾛ"),
                .KomojiDakuten,
                seq("ﾜｦﾝ-"),
                seqWithSymbols("、。？！"),
                ]),
            .Number: KeyPad(keys: [
                seqWithSymbols("1←↑→↓"),
                seqWithSymbols("2"),
                seqWithSymbols("3"),
                seqWithSymbols("4"),
                seqWithSymbols("5"),
                seqWithSymbols("6"),
                seqWithSymbols("7"),
                seqWithSymbols("8"),
                seqWithSymbols("9"),
                seqWithSymbols("()[]"),
                seqWithSymbols("0～⋯"),
                seqWithSymbols(".,-/"),
                ]),
            .Alphabet: KeyPad(keys: [
                seqWithSymbols("@#/&_"),
                seq("abc"),
                seq("def"),
                seq("ghi"),
                seq("jkl"),
                seq("mno"),
                seq("pqrs"),
                seq("tuv"),
                seq("wxyz"),
                .UpperLower,
                seqWithSymbols("'\"()"),
                seqWithSymbols(".,?!"),
                ]),
        ]

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        for keypad in self.keypads.values {
            keypad.tapped = { [weak self] (key:KanaFlickKey, index:Int?) in
                self?.keyTapped(key, index)
                return
            }
        }

        dictionary.addObserver(self, forKeyPath: SKKDictionary.isWaitingForLoadKVOKey(), options: NSKeyValueObservingOptions.allZeros, context: nil)
        updateControlButtons()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        dictionary.removeObserver(self, forKeyPath: SKKDictionary.isWaitingForLoadKVOKey())
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

        let leftControl = controlViewWithButtons([
            numberModeButton,
            alphabetModeButton,
            inputModeChangeButton,
            nextKeyboardButton,
            ])
        let rightControl = controlViewWithButtons([
            keyButton(.Backspace),
            self.spaceButton,
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
        
        sessionView.didSelectCandidateAtIndex = { [weak self] index in
            self?.engine.handle(.Select(index : index))
            return
        }
        sessionView.composeText = AppGroup.initialText()

        updateControlButtons()

        KeyButtonFlickPopup.sharedInstance.parentView = inputView

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

        if sessionView.isDescendantOfView(view) {
            return
        }

        let views = [
            "sessionView": sessionView,
            "progress": loadingProgressView,
            "keypadAndControls": keypadAndControlsView,
        ]
        let autolayout = self.inputView.autolayoutFormat(metrics, views)
        autolayout("H:|[sessionView]|")
        autolayout("H:|[progress]")
        autolayout("H:|[keypadAndControls]|")
        autolayout("V:|[sessionView(==30)][keypadAndControls]|")
        autolayout("V:|[progress(==sessionView)]")

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
        case let .Seq(s, _):
            let kana = Array(s)[index ?? 0]
            self.engine.handle(.Char(kana: String(kana), shift: self.shiftEnabled))
            self.prevShiftEnabled = self.shiftEnabled
            self.shiftEnabled = false
        case .Backspace:
            self.engine.handle(.Backspace)
            self.shiftEnabled = self.prevShiftEnabled
            self.prevShiftEnabled = false
        case .Return:
            self.engine.handle(.Enter)
        case .Shift: toggleShift()
        case .KeyboardChange:
            advanceToNextInputMode()
        case .InputModeChange(let modes):
            switch modes[index ?? 0] {
            case .Some(let m):
                self.engine.handle(.InputModeChange(inputMode: m))
            case .None:
                break
            }
            self.keyboardMode = .InputMode(mode: self.inputMode)
        case .Number:
            self.keyboardMode = .Number
        case .Alphabet:
            self.keyboardMode = .Alphabet
        case .KomojiDakuten: self.toggleKomojiDakuten()
        case .UpperLower: self.toggleUpperLower()
        case .Space:
            if index.map({$0 > 0}) ?? false {
                self.handleSkipPartialCandidates()
            } else {
                self.handleSpace()
            }
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

        switch self.inputMode {
        case .Hirakana:
            self.inputModeChangeButton.label.text = "かな"
        case .Katakana:
            self.inputModeChangeButton.label.text = "カナ"
        case .HankakuKana:
            self.inputModeChangeButton.label.text = "ｶﾅ"
        }
        
        updateSpaceButtonLabel()
    }
    
    private func updateSpaceButtonLabel() {
        let normal = self.spaceButton.key.buttonLabel
        let nextCandidate = NSLocalizedString("NextCandidate", comment: "")
        self.spaceButton.label.text = (self.engine.inStatusShowsCandidatesBySpace() ?? false) ? nextCandidate : normal
        self.spaceButton.flicksEnabled = self.engine.hasPartialCandidates
    }

    func toggleShift() {
        self.shiftEnabled = !self.shiftEnabled
    }

    func handleSpace() {
        engine.handle(.Space)
    }
    
    func handleSkipPartialCandidates() {
        engine.handle(.SkipPartialCandidates)
    }

    func toggleKomojiDakuten() {
        self.engine.handle(.ToggleDakuten(beforeText: self.inputProxy.documentContextBeforeInput ?? ""))
    }

    func toggleUpperLower() {
        self.engine.handle(.ToggleUpperLower(beforeText: self.inputProxy.documentContextBeforeInput ?? ""))
    }

    func composeText(text: String) {
        self.sessionView.composeText = text
        
        self.updateSpaceButtonLabel()
    }

    func showCandidates(candidates: [Candidate]?) {
        sessionView.canEnterWordRegister = candidates != nil
        sessionView.candidates = candidates ?? []
        
        self.updateSpaceButtonLabel()
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
        (self.textDocumentProxy as! UIKeyInput).deleteBackward()
    }

    func changeInputMode(inputMode : SKKInputMode) {
        self.inputMode = inputMode
        updateControlButtons()
    }
}
