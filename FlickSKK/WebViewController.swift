//
//  WebViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit
import Ikemen

class WebViewController: UIViewController, UIWebViewDelegate {
    lazy var webView: UIWebView = UIWebView(frame: CGRect.zero) ※ { (wv: inout UIWebView) in
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.scalesPageToFit = true
        wv.delegate = self
        wv.dataDetectorTypes = UIDataDetectorTypes.link
    }

    var initialURL: URL?

    init(URL: Foundation.URL) {
        self.initialURL = URL
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.webView

        if let u = initialURL {
            self.webView.loadRequest(URLRequest(url: u))
        }
    }

    // MARK: WebView Delegate

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            // Open in Safari
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let title = self.webView.stringByEvaluatingJavaScript(from: "document.title") {
            self.title = title
        }
    }

    // MARK: -

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
