//
//  WebViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/19.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    var webView: UIWebView!
    var initialURL: NSURL?

    init(URL: NSURL) {
        self.initialURL = URL
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.webView = UIWebView(frame: CGRectZero).tap{ (wv:UIWebView) in
            wv.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            wv.scalesPageToFit = true
            wv.delegate = self
            wv.dataDetectorTypes = UIDataDetectorTypes.Link
        }
        self.view = self.webView

        if let u = initialURL {
            self.webView.loadRequest(NSURLRequest(URL: u))
        }
    }

    // MARK: WebView Delegate

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            // Open in Safari
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        return true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        if let title = self.webView.stringByEvaluatingJavaScriptFromString("document.title") {
            self.title = title
        }
    }

    // MARK: -

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
