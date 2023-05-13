class MockDelegate : SKKDelegate {
    var insertedText = ""
    var inputMode : SKKInputMode = .hirakana

    func insertText(_ text : String) {
        self.insertedText += text
    }

    func deleteBackward() {
        self.insertedText = self.insertedText.butLast()
    }

    func composeText(_ text :String?, markedText: String?) {
    }

    func changeInputMode(_ inputMode: SKKInputMode) {
        self.inputMode = inputMode
    }

    func showCandidates(_ candidates : [Candidate]?) {
    }
}
