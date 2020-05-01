//
//  AboutViewController.swift
// 
//  Fluor
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var webpageButton: NSButton!
    @IBOutlet weak var twitterButton: NSButton!
    @IBOutlet weak var githubButton: NSButton!
    @IBOutlet weak var supportButton: NSButton!
    @IBOutlet weak var iconView: NSImageView!

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
    
    private func openUrlForInfo(key: String) {
        guard let url = self.urlForInfo(key: key) else { return }
        NSWorkspace.shared.open(url)
    }
    
    private func urlForInfo(key: String) -> URL? {
        guard let str = Bundle.main.infoDictionary?[key] as? String,
            let url = URL(string: str) else { return nil }
        
        return url
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
        self.openUrlForInfo(key: "FLSupportEmail")
    }
}
