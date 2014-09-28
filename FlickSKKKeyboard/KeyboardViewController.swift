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
    case Hirakana
    case Katakana
    case Number
    case KomojiDakuten
    case Nothing
    
    var buttonLabel: String {
        switch self {
        case let .Seq(s): return String(s[s.startIndex])
        case .Shift: return "⇧"
        case .Return: return "⏎"
        case .Backspace: return "⌫"
        case .Hirakana: return "かな"
        case .Katakana: return "カナ"
        case .Number: return "123"
        case .KomojiDakuten: return "小゛゜"
        case .Nothing: return ""
        }
    }
    
    var sequence: String? {
        switch self {
        case let .Seq(s): return s
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
        case .Hirakana: return 4
        case .Katakana: return 5
        case .Number: return 6
        case .KomojiDakuten: return 7
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


enum SKKInputMode {
    case Hirakana
    case Katakana
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


class KeyboardViewController: UIInputViewController {
    let keypadAndControlsView = UIView()
    let contextView = UIView()
    
    let nextKeyboardButton: UIButton!
    var inputProxy: UITextDocumentProxy {
        return self.textDocumentProxy as UITextDocumentProxy
    }
    
    let modeButtons: [SKKInputMode:KeyButton]!
    let shiftButton: KeyButton!
    let keypads: [SKKInputMode:KeyPad]
    
    var shiftEnabled: Bool {
        didSet {
            updateControlButtons()
        }
    }
    var inputMode: SKKInputMode {
        didSet {
            updateControlButtons()
        }
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.shiftEnabled = false
        self.inputMode = .Hirakana
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
                .Seq("わをん"),
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
                .Seq("ワヲン"),
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
        self.shiftButton = keyButton(.Shift)
        self.modeButtons = [
            .Hirakana: keyButton(.Hirakana),
            .Katakana: keyButton(.Katakana),
            .Number: keyButton(.Number),
        ]
        
        for keypad in self.keypads.values {
            keypad.tapped = { (key:KanaFlickKey, index:Int?) in
                self.keyTapped(key, index)
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var metrics: [String:CGFloat] {
        return [:]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftControl = controlViewWithButtons([
            self.modeButtons[.Number]!,
            self.modeButtons[.Hirakana]!,
            self.modeButtons[.Katakana]!,
            nextKeyboardButton,
            ])
        let rightControl = controlViewWithButtons([
            keyButton(.Backspace),
            keyButton(.Nothing),
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
        
        let views = [
            "context": contextView,
            "keypadAndControls": keypadAndControlsView,
        ]
        let autolayout = self.inputView.autolayoutFormat(metrics, views)
        autolayout("H:|[context]|")
        autolayout("H:|[keypadAndControls]|")
        autolayout("V:|[context(==44)]")
        autolayout("V:|[keypadAndControls]|")
        self.inputView.bringSubviewToFront(contextView)
        contextView.hidden = true
        
        updateControlButtons()
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
        return KeyButton(key: key).tap { [unowned self] (b:KeyButton) in
            b.tapped = { (key:KanaFlickKey, index:Int?) in
                self.keyTapped(key, index)
            }
        }
    }
    
    func insertText(s: String) {
        self.inputProxy.insertText(s)
        self.updateControlButtons()
    }
    
    func keyTapped(key: KanaFlickKey, _ index: Int?) {
        switch key {
        case let .Seq(s): self.insertText(String(Array(s)[index ?? 0]))
        case .Backspace: self.inputProxy.deleteBackward()
        case .Return: self.insertText("\n")
        case .Shift: toggleShift()
        case .Hirakana: self.inputMode = .Hirakana
        case .Katakana: self.inputMode = .Katakana
        case .Number: self.inputMode = .Number
        case .KomojiDakuten: self.toggleKomojiDakuten()
        case .Nothing: break
        }
    }
    
    func updateControlButtons() {
        for (mode, button) in self.modeButtons {
            button.selected = (mode == self.inputMode)
        }
        
        for (mode, keypad) in self.keypads {
            keypad.hidden = !(mode == self.inputMode)
        }
        
        self.shiftButton.selected = self.shiftEnabled
        
        for keypad in self.keypads.values {
            for b in keypad.keyButtons.filter({ $0.key == .KomojiDakuten }) {
                b.enabled = self.canConvertKomojiDakuten
            }
        }
        
        // default implementation
        self.nextKeyboardButton.setTitleColor(inputProxy.keyboardAppearance == UIKeyboardAppearance.Dark ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
    }
    
    func toggleShift() {
        self.shiftEnabled = !self.shiftEnabled
    }
    
    var canConvertKomojiDakuten: Bool {
        let beforeString = self.inputProxy.documentContextBeforeInput ?? ""
        if (beforeString as NSString).length == 0 || beforeString.hasSuffix(komojiDakutenConversionsSkip) { return false }
        let lastString = String(Array(beforeString).last!)
        
        for i in 0..<komojiDakutenConversions.count {
            if let r = komojiDakutenConversions[i].rangeOfString(lastString) {
                return true
            }
        }
        return false
    }
    
    let komojiDakutenConversions = [
        "あいうえおかきくけこさしすせそたちつてとはひふへほやゆよアイウエオカキクケコサシスセソタチツテトハヒフヘホヤユヨ",
        "ぁぃぅぇぉがぎぐげござじずぜぞだぢっでどばびぶべぼゃゅょァィゥェォガギグゲゴザジズゼゾダヂッデドバビブベボャュョ",
        "ーーーーーーーーーーーーーーーーーづーーぱぴぷぺぽーーーーーーーーーーーーーーーーーーーーヅーーパピプペポーーー",
    ]
    let komojiDakutenConversionsSkip = "ー"
    
    func toggleKomojiDakuten() {
        if !self.canConvertKomojiDakuten { return }
        let lastString = String(Array(self.inputProxy.documentContextBeforeInput).last ?? Character(""))
        
        for i in 0..<komojiDakutenConversions.count {
            if let r = komojiDakutenConversions[i].rangeOfString(lastString) {
                var next = String(komojiDakutenConversions[(i + 1) % komojiDakutenConversions.count][r.startIndex])
                if next == komojiDakutenConversionsSkip {
                    next = String(komojiDakutenConversions[(i + 2) % komojiDakutenConversions.count][r.startIndex])
                }
                self.inputProxy.deleteBackward()
                self.insertText(String(next))
                return
            }
        }
    }
}
