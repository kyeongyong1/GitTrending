//
//  DetailWebViewController.swift
//  KIGitTrending
//
//  Created by Lee on 2017. 6. 25..
//  Copyright © 2017년 KI. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SnapKit

class DetailWebViewController: UIViewController {
    
    var webView: WKWebView!
    var request: URLRequest!
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        
        webView = WKWebView()
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(toolBar.snp.top)
        }
        webView.load(request)
        self.view.bringSubview(toFront: toolBar)
    }

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @IBAction func goButton(_ sender: UIBarButtonItem) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
}

