//
//  ReleaseNotesViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 20/02/2019.
//  Copyright © 2019 Pyrolyse. All rights reserved.
//

import Cocoa
import WebKit

class ReleaseNotesViewController: NSViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    func show(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        self.webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated{
            if let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
            }
            
            decisionHandler(.cancel)
        }
    }
}
