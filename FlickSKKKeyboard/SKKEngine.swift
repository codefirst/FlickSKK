// SKKのメインエンジン

class SKKEngine {
    private let keyHandler : KeyHandler
    private weak var delegate : SKKDelegate!

    private var inputMode : SKKInputMode = .Hirakana
    private var composeMode : ComposeMode = .DirectInput

    private let presenter = ComposeModePresenter()

    init(delegate : SKKDelegate, dictionary : SKKDictionary){
        self.delegate = delegate
        self.keyHandler = KeyHandler(delegate: delegate, dictionary: dictionary)
    }

    func currentInputMode() -> SKKInputMode {
        return self.inputMode
    }

    func currentComposeMode() -> ComposeMode {
        return self.composeMode
    }

    func handle(keyEvent : SKKKeyEvent) {
        // 状態遷移
        self.composeMode = keyHandler.handle(keyEvent, composeMode: composeMode)

        // 表示を更新
        self.delegate.composeText(presenter.toString(self.composeMode))

        // 候補表示
        self.delegate.showCandidates(candidates()?.0)
    }
    
    func candidates() -> ([String], Int)? {
        return self.presenter.candidates(self.composeMode)
    }
}
