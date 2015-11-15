import Foundation
import UIKit

// 3Dタッチされているかを判断する。
//
//  - 強く押されたとこの検知
//  - hapticを用いたときのフィードバック
//  - 画面へのぼかしの適用のハンドリング
//
// を行なう。
//
// ## 準備
//
// 押下された際に発生する `UITouch` と、指が離されたことを伝える。
//
// ```
// override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//   // UITouchを伝える
//   ForceTouch.sharedInstance.fires(touches, source: self)
// }
//
// override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//   // 指が離れたことを伝える
//   ForceTouch.sharedInstance.end()
//   super.touchesEnded(touches, withEvent: event)
// }
// ```
//
// ## 強く押されたことの検出
//
// ```
// override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//   // UITouchを伝える(前述)
//   ForceTouch.sharedInstance.fires(touches, source: self)
//
//   // 強く押されたときの処理
//   if (ForceTouch.sharedInstance.forceTouched()) {
//     doSomething()
//   }
// }
// ```
//
// ## 画面へのぼかしの適用
//
// 押されている強さに応じて、画面をぼかすなどの処理をしたほうが分かりやすい。
//
// ```
// override func viewDidAppear(animated: Bool) {
//   // ぼかし用のUIImageViewを追加する
//   let effect = UIImageView()
//   self.view.addSubView(effect)
//
//   // 押下されたら、スクリーンショットを取得しておく
//   var screenshot : UIImage!
//   ForceTouch.sharedInstance.startSession = { view in
//     screenshot = self.obtainScreenshot()
//     effect.hidden = false
//   }
//
//   // ぼかしを適用する
//   ForceTouch.sharedInstance.applyBlur = { r in
//     // https://gist.github.com/neilkimmett/10145867
//     effect.image = screenshot.applyBlurWithRadius(radius, tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)
//   }
//
//   // 終了したら、各種データを開放する
//   ForceTouch.sharedInstance.endSession = {
//     screenshot = nil
//     effect.image = nil
//     effect.hidden = true
//   }
// }
//
// // 画面のスクリーンショットの取得
// private func obtainScreenshot() -> UIImage {
//   UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
//   defer { UIGraphicsEndImageContext() }
//   self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
//   return UIGraphicsGetImageFromCurrentImageContext()
// }
// ```
class ForceTouch : NSObject {
    // MARK: singleton
    static let sharedInstance = ForceTouch()

    // MARK: threshold
    private let MAX_THRESHOLD : CGFloat = 4.0
    private let MIN_THRESHOLD : CGFloat = 0.4

    // MARK: observer
    var startSession : (UIView -> Void)?
    var endSession : (Void -> Void)?
    var applyBlur : (CGFloat -> Void)?

    // MARK: KeyButton interface
    private var forced : Bool = false
    func forceTouched() -> Bool {
        return forced
    }

    // MARK: Event source
    private var prevAlpha : CGFloat = 0.0

    func fire(touch : UITouch, source : UIView) {
        let alpha = min(1, max(0, force(touch) - MIN_THRESHOLD) / MAX_THRESHOLD)

        if alpha != 0.0 {
            if prevAlpha == 0.0 {
                startSession?(source)
            }
            if !forced && alpha == 1.0 {
                forced = true
                UIDevice.currentDevice()._tapticEngine().actuateFeedback(1001)
            }
            applyBlur?(alpha)
            prevAlpha = alpha
        }
    }

    func fires(touches : Set<UITouch>, source : UIView) {
        if let touch = touches.maxElement({ self.force($0) < self.force($1) }) {
            fire(touch, source: source)
        }
    }

    func end() {
        self.prevAlpha = 0.0
        self.forced = false
        endSession?()
    }

    private func force(touch : UITouch) -> CGFloat {
        if #available(iOSApplicationExtension 9.0, *) {
            return touch.force
        } else {
            return 0.0
        }
    }
}