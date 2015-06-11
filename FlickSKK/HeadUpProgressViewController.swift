import UIKit
import NorthLayout

// プログレスバーを全面に半透明で表示する。
//
// 途中キャンセルとかあったほうがいいんだけど、面倒なのであとまわし。
// それほどサイズが大きい辞書をDLしないだろうし、たぶん問題になることはすくないはず。
class HeadUpProgressViewController: UIViewController {
    private let progressView : UIProgressView
    private let label = UILabel()

    var progress : Float? {
        didSet {
            self.updateProgress()
        }
    }

    var text : String?

    init() {
        progressView = UIProgressView()
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .OverFullScreen
        modalTransitionStyle = .CrossDissolve
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)

        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center

        let autolayout = view.northLayoutFormat(["p":8, "h" : 10],
            ["progress": progressView, "label" : label])
        autolayout("H:|-p-[progress]-p-|")
        autolayout("H:|-p-[label]-p-|")

        // 画面中央に表示する
        self.view.addConstraint(NSLayoutConstraint(item: progressView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))

        // ラベルをプログレスバーのちょっと下に表示する
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: progressView, attribute: .Bottom, multiplier: 1, constant: 10))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    private func updateProgress() {
        // メインスレッドで更新しないとプログレスバーが反映されない
        dispatch_async(dispatch_get_main_queue()) {
            self.label.text = self.text
            self.progressView.setProgress(self.progress ?? 0.0, animated: true)
        }
    }

    func close(completion: (() -> Void)? = nil) {
        dismissViewControllerAnimated(true, completion: completion)
    }
}
