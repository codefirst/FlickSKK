import Foundation
import UIKit

// UIPanGestureRecognizer を拡張し、gestureRecognizerがcallbackされるようにする
class PanGestureRecognizer : UIPanGestureRecognizer {
    override func touchesMoved(touches: Set<UITouch>, withEvent: UIEvent?) {
        for touch in touches {
            delegate?.gestureRecognizer?(self, shouldReceiveTouch: touch)
        }
        super.touchesMoved(touches, withEvent: withEvent)
    }
}
