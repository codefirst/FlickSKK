class MockDelegate : SKKDelegate {
    var insertedText = ""
    var inputMode : SKKInputMode = .Hirakana

    func insertText(text : String) {
        self.insertedText += text
    }

    func deleteBackward() {
        self.insertedText = self.insertedText.butLast()
    }

    func composeText(text : String) {
    }

    func changeInputMode(inputMode: SKKInputMode) {
        self.inputMode = inputMode
    }

    func showCandidates(candidates : [Candidate]?) {
    }
}
