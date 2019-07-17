//
//  KeyboardViewController.swift
//  FlickSKKKeyboard
//
//  Created by BAN Jun on 2014/09/27.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit
import NorthLayout
import Ikemen

class KeyboardViewController: UIInputViewController, SKKDelegate {
    lazy var heightConstraint : NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 216)

    let keypadAndControlsView = UIView()
    let loadingProgressView = UIActivityIndicatorView(style: .gray)

    lazy var sessionView : SessionView = SessionView(engine: self.engine)

    var inputProxy: UITextDocumentProxy {
        return self.textDocumentProxy 
    }

    // MARK: Status
    var inputMode : SKKInputMode = .hirakana
    var prevShiftEnabled: Bool = false
    var shiftEnabled: Bool { didSet { updateControlButtons() } }
    var keyboardMode : KeyboardMode { didSet { updateControlButtons() } }

    // MARK: SKK
    lazy var engine : SKKEngine = SKKEngine(delegate: self, dictionary: self.dictionary)
    lazy var dictionary : SKKDictionary = SKKDictionary()

    // MARK: Keypads
    let keypads: [KeyboardMode:KeyPad]

    // MARK: Buttons
    lazy var inputModeChangeButton : KeyButton = self.keyButton(.inputModeChange([nil, nil, .hirakana, .katakana, .hankakuKana]))
    lazy var numberModeButton : KeyButton = self.keyButton(.number)
    lazy var alphabetModeButton : KeyButton = self.keyButton(.alphabet)
    lazy var spaceButton : KeyButton = self.keyButton(.space)
    lazy var nextKeyboardButton : KeyButton = self.keyButton(.keyboardChange) ※ { (kb:inout KeyButton) in
        kb.imageView.image = UIImage(named: "globe")
    }
    lazy var shiftButton: KeyButton = self.keyButton(.shift) ※ { (kb:inout KeyButton) in
        kb.imageView.image = UIImage(named: "flickskk-arrow")
    }

    // MARK: -

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.keyboardMode = .inputMode(mode: .hirakana)
        self.shiftEnabled = false
        let seq = {(s: String) -> KanaFlickKey in .seq(s, showSeqs: false)}
        let seqWithSymbols = {(s: String) -> KanaFlickKey in .seq(s, showSeqs: true)}
        self.keypads = [
            .inputMode(mode: .hirakana): KeyPad(keys: [
                seq("あいうえお"),
                seq("かきくけこ"),
                seq("さしすせそ"),
                seq("たちつてと"),
                seq("なにぬねの"),
                seq("はひふへほ"),
                seq("まみむめも"),
                seq("や「ゆ」よ"),
                seq("らりるれろ"),
                .komojiDakuten,
                seq("わをんー"),
                seqWithSymbols("、。？！"),
                ]),
            .inputMode(mode: .katakana): KeyPad(keys: [
                seq("アイウエオ"),
                seq("カキクケコ"),
                seq("サシスセソ"),
                seq("タチツテト"),
                seq("ナニヌネノ"),
                seq("ハヒフヘホ"),
                seq("マミムメモ"),
                seq("ヤ「ユ」ヨ"),
                seq("ラリルレロ"),
                .komojiDakuten,
                seq("ワヲンー"),
                seqWithSymbols("、。？！"),
                ]),
            .inputMode(mode: .hankakuKana): KeyPad(keys: [
                seq("ｱｲｳｴｵ"),
                seq("ｶｷｸｹｺ"),
                seq("ｻｼｽｾｿ"),
                seq("ﾀﾁﾂﾃﾄ"),
                seq("ﾅﾆﾇﾈﾉ"),
                seq("ﾊﾋﾌﾍﾎ"),
                seq("ﾏﾐﾑﾒﾓ"),
                seq("ﾔ｢ﾕ｣ﾖ"),
                seq("ﾗﾘﾙﾚﾛ"),
                .komojiDakuten,
                seq("ﾜｦﾝ-"),
                seqWithSymbols("､｡?!"),
                ]),
            .number: KeyPad(keys: [
                // よく使う記号(アルファベットキーにあわせた)
                seqWithSymbols("1#@&_"),
                // 通貨用記号
                seqWithSymbols("2$￥"),
                // 直線で構成されているやつ。左右キーが対応してるやつなので右端にする。
                seqWithSymbols("3\\^/|"),
                // 算術記号(%がmodなのは自明か?)
                seqWithSymbols("4+*%="),
                // 矢印。中央においてみた。
                seqWithSymbols("5←↑→↓"),
                // 括弧系(1)
                seqWithSymbols("6([)]"),
                // 引用記号
                seqWithSymbols("7'\"`~"),
                // 行末記号と区切り文字
                seqWithSymbols("8?:!;"),
                // 括弧系(2)
                seqWithSymbols("9<{>}"),
                // 全角記号
                seqWithSymbols("☆✿※♪"),
                // 行末で使う全角記号
                seqWithSymbols("0～・…"),
                // 標準キーボードにあわせた
                seqWithSymbols(".,-/"),
                ]),
            .alphabet: KeyPad(keys: [
                seqWithSymbols("@#/&_"),
                seq("abc"),
                seq("def"),
                seq("ghi"),
                seq("jkl"),
                seq("mno"),
                seq("pqrs"),
                seq("tuv"),
                seq("wxyz"),
                .upperLower,
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

        dictionary.addObserver(self, forKeyPath: SKKDictionary.isWaitingForLoadKVOKey(), options: NSKeyValueObservingOptions(), context: nil)
        updateControlButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        dictionary.removeObserver(self, forKeyPath: SKKDictionary.isWaitingForLoadKVOKey())
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let dict = object as? SKKDictionary {
            if dict.isWaitingForLoad {
                self.disableAllKeys()
                loadingProgressView.startAnimating()
            } else {
                self.enableAllKeys()
                loadingProgressView.stopAnimating()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
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
            keyButton(.backspace),
            self.spaceButton,
            self.shiftButton,
            keyButton(.return),
            ])

        for keypad in self.keypads.values {
            let views = [
                "left": leftControl,
                "right": rightControl,
                "keypad": keypad,
            ]
            let autolayout = self.keypadAndControlsView.northLayoutFormat(metrics, views)
            autolayout("H:|[left][keypad][right(==left)]|")
            autolayout("V:|[left]|")
            autolayout("V:|[keypad]|")
            autolayout("V:|[right]|")
            self.keypadAndControlsView.addConstraint(NSLayoutConstraint(item: keypad, attribute: .width, relatedBy: .equal, toItem: leftControl, attribute: .width, multiplier: 3.0, constant: 0.0))
        }

        sessionView.didSelectCandidateAtIndex = { [weak self] index in
            self?.engine.handle(.select(index : index))
            return
        }

        updateControlButtons()

        KeyButtonFlickPopup.sharedInstance.parentView = inputView

        // iOS8 layout height(0) workaround: call self.inputView.addSubview() after viewDidAppear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupViewConstraints() // iOS8 layout height(0) workaround: setup constraints after view did appear
        // keyboard height can be changed, but cause some layout errors.
        // 'UIView-Encapsulated-Layout-Height' V:[UIInputView:...(216)]
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//            self.heightConstraint.constant += 100
//        }
    }

    fileprivate func setupViewConstraints() {
        if view.frame.isEmpty {
            print("\(#function): empty view. ignored.")
            return
        }

        if sessionView.isDescendant(of: view) {
            return
        }

        let views = [
            "sessionView": sessionView,
            "progress": loadingProgressView,
            "keypadAndControls": keypadAndControlsView,
        ]
        if let autolayout = self.inputView?.northLayoutFormat(metrics, views) {
            autolayout("H:|[sessionView]|")
            autolayout("H:|[progress]")
            autolayout("H:|[keypadAndControls]|")
            autolayout("V:|[sessionView(==30)][keypadAndControls]|")
            autolayout("V:|[progress(==sessionView)]")
        }

        self.view.addConstraint(heightConstraint);
    }

    func controlViewWithButtons(_ buttons: [UIView]) -> UIView {
        if (buttons.count != 4) { print("fatal: cannot add buttons not having 4 buttons to control"); return UIView(); }

        let views = [
            "a": buttons[0],
            "b": buttons[1],
            "c": buttons[2],
            "d": buttons[3],
        ]

        return UIView() ※ { (c:inout UIView) in
            let autolayout = c.northLayoutFormat(self.metrics, views)
            autolayout("H:|[a]|")
            autolayout("H:|[b]|")
            autolayout("H:|[c]|")
            autolayout("H:|[d]|")
            autolayout("V:|[a][b(==a)][c(==a)][d(==a)]|")
        }
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.

        updateControlButtons()
    }

    fileprivate func keyButton(_ key: KanaFlickKey) -> KeyButton {
        return KeyButton(key: key) ※ { (b:inout KeyButton) in
            weak var weakSelf = self
            b.tapped = { (key:KanaFlickKey, index:Int?) in
                weakSelf?.keyTapped(key, index)
                return
            }
        }
    }

    func insertText(_ s: String) {
        self.inputProxy.insertText(s)
        self.shiftEnabled = false
        self.updateControlButtons()
    }

    func keyTapped(_ key: KanaFlickKey, _ index: Int?) {
        switch key {
        case let .seq(s, _):
            let kana = Array(s)[index ?? 0]
            self.engine.handle(.char(kana: String(kana), shift: self.shiftEnabled))
            self.prevShiftEnabled = self.shiftEnabled
            self.shiftEnabled = false
        case .backspace:
            self.engine.handle(.backspace)
            self.shiftEnabled = self.prevShiftEnabled
            self.prevShiftEnabled = false
        case .return:
            self.engine.handle(.enter)
        case .shift: toggleShift()
        case .keyboardChange:
            advanceToNextInputMode()
        case .inputModeChange(let modes):
            switch modes[index ?? 0] {
            case .some(let m):
                self.engine.handle(.inputModeChange(inputMode: m))
            case .none:
                break
            }
            self.keyboardMode = .inputMode(mode: self.inputMode)
        case .number:
            self.keyboardMode = .number
        case .alphabet:
            self.keyboardMode = .alphabet
        case .komojiDakuten: self.toggleKomojiDakuten()
        case .upperLower: self.toggleUpperLower()
        case .space:
            if index.map({$0 > 0}) ?? false {
                self.handleSkipPartialCandidates()
            } else {
                self.handleSpace()
            }
        case .nothing: break
        }
        updateControlButtons()
    }

    func updateControlButtons() {
        // Keyboard mode
        for (mode, keypad) in self.keypads {
            keypad.isHidden = !(mode == keyboardMode)
        }

        // each button
        switch(self.keyboardMode) {
        case .inputMode(_):
            self.inputModeChangeButton.selected = true
        default:
            self.inputModeChangeButton.selected = false
        }
        self.numberModeButton.selected = self.keyboardMode == .number
        self.alphabetModeButton.selected = self.keyboardMode == .alphabet
        self.shiftButton.selected = self.shiftEnabled

        switch self.inputMode {
        case .hirakana:
            self.inputModeChangeButton.label.text = "かな"
        case .katakana:
            self.inputModeChangeButton.label.text = "カナ"
        case .hankakuKana:
            self.inputModeChangeButton.label.text = "ｶﾅ"
        }

        updateSpaceButtonLabel()
    }

    fileprivate func updateSpaceButtonLabel() {
        let normal = self.spaceButton.key.buttonLabel
        let nextCandidate = NSLocalizedString("NextCandidate", comment: "")
        self.spaceButton.label.text = (self.engine.inStatusShowsCandidatesBySpace()) ? nextCandidate : normal
        self.spaceButton.flicksEnabled = self.engine.hasPartialCandidates
    }

    func toggleShift() {
        self.shiftEnabled = !self.shiftEnabled
    }

    func handleSpace() {
        engine.handle(.space)
    }

    func handleSkipPartialCandidates() {
        engine.handle(.skipPartialCandidates)
    }

    func toggleKomojiDakuten() {
        self.engine.handle(.toggleDakuten(beforeText: self.inputProxy.documentContextBeforeInput ?? ""))
    }

    func toggleUpperLower() {
        self.engine.handle(.toggleUpperLower(beforeText: self.inputProxy.documentContextBeforeInput ?? ""))
    }

    func composeText(_ text: String, currentCandidate: Candidate?) {
        self.sessionView.composeText = text

        if #available(iOS 13.0, iOSApplicationExtension 13.0, *) {
            let markedText = currentCandidate?.kanji ?? text
            inputProxy.setMarkedText(markedText, selectedRange: NSRange(location: (markedText as NSString).length, length: 0))
        }

        self.updateSpaceButtonLabel()
    }

    func showCandidates(_ candidates: [Candidate]?) {
        sessionView.canEnterWordRegister = candidates != nil
        sessionView.candidates = candidates ?? []

        self.updateSpaceButtonLabel()
    }

    fileprivate let userInteractionMaskView = UIView()
    fileprivate func disableAllKeys() {
        userInteractionMaskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        userInteractionMaskView.frame = self.view.bounds
        userInteractionMaskView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        if userInteractionMaskView.superview == nil {
            self.view.addSubview(userInteractionMaskView)
        } else {
            self.view.bringSubviewToFront(userInteractionMaskView)
        }
    }
    fileprivate func enableAllKeys() {
        userInteractionMaskView.removeFromSuperview()
    }

    func deleteBackward() {
        (self.textDocumentProxy as UIKeyInput).deleteBackward()
    }

    func changeInputMode(_ inputMode : SKKInputMode) {
        self.inputMode = inputMode
        updateControlButtons()
    }
}
