//
//  WebViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit
import Ikemen
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    lazy var configure = WKWebViewConfiguration() ※ { (wc: inout WKWebViewConfiguration) in
        wc.dataDetectorTypes = .link
    }
    lazy var webView: WKWebView = WKWebView(frame: CGRect.zero, configuration: configure) ※ { (wv: inout WKWebView) in
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.navigationDelegate = self
    }

    var initialURL: URL?

    init(URL: Foundation.URL) {
        self.initialURL = URL
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.webView
        view.backgroundColor = ThemeColor.background
        webView.isOpaque = false // https://stackoverflow.com/questions/27655930/how-can-i-give-wkwebview-a-colored-background

        if let u = initialURL {
            self.webView.load(URLRequest(url: u))
        }
    }

    // MARK: WebView Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            // Open in Safari
            UIApplication.shared.open(navigationAction.request.url!, options: [:]) { _ in }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (result : Any?, _) in
            if let title = result as? String {
                self.title = title
            }
        }
    }

    // MARK: -

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
