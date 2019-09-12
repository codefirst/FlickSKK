import UIKit
import NorthLayout

// プログレスバーを全面に半透明で表示する。
//
// 途中キャンセルとかあったほうがいいんだけど、面倒なのであとまわし。
// それほどサイズが大きい辞書をDLしないだろうし、たぶん問題になることはすくないはず。
class HeadUpProgressViewController: UIViewController {
    fileprivate let progressView : UIProgressView
    fileprivate let label = UILabel()

    var progress : Float? {
        didSet {
            self.updateProgress()
        }
    }

    var text : String?

    init() {
        progressView = UIProgressView()
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = ThemeColor.hudBackground

        label.textColor = ThemeColor.invertedText
        label.textAlignment = .center

        let autolayout = view.northLayoutFormat(["p":8, "h" : 10],
            ["progress": progressView, "label" : label])
        autolayout("H:|-p-[progress]-p-|")
        autolayout("V:[progress]-p-[label]")
        autolayout("H:|-p-[label]-p-|")

        // 画面中央に表示する
        self.view.addConstraint(NSLayoutConstraint(item: progressView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    fileprivate func updateProgress() {
        // メインスレッドで更新しないとプログレスバーが反映されない
        DispatchQueue.main.async {
            self.label.text = self.text
            self.progressView.setProgress(self.progress ?? 0.0, animated: true)
        }
    }

    func close(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: completion)
        }
    }
}
