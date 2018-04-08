//
//  AboutViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 26/03/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var webpageButton: NSButton!
    @IBOutlet weak var twitterButton: NSButton!
    @IBOutlet weak var githubButton: NSButton!
    @IBOutlet weak var supportButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundleVersion = getBundleVersion()
        versionLabel.stringValue = "Version \(bundleVersion.version) build \(bundleVersion.build)"
    }
    
    private func getBundleVersion() -> (version: String, build: String) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        return (version, build)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func goToWebpage(_ sender: Any) {
        self.openUrlForInfo(key: "FLPyrolyseURL")
    }
    
    @IBAction func goToTwitter(_ sender: Any) {
        self.openUrlForInfo(key: "FLTwitterURL")
    }
    
    @IBAction func goToGithub(_ sender: Any) {
        self.openUrlForInfo(key: "FLGithubURL")
    }
    
    @IBAction func goToSupport(_ sender: Any) {
        if let mailURL = URL(string: "mailto:fluor.support@pyrolyse.it?subject=Fluor%20Issue") {
            NSWorkspace.shared.open(mailURL)
        }
    }
    
    private func openUrlForInfo(key: String) {
        guard let str = Bundle.main.infoDictionary?[key] as? String,
            let url = URL(string: str) else {
                return
        }
        NSWorkspace.shared.open(url)
    }
}
