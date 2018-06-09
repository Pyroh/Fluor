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
    @IBOutlet weak var iconView: NSImageView!
    
    @objc dynamic var hasReleaseNotes: Bool = false
    
    private var releaseNotesURL: URL? {
        let version = self.getBundleVersion().version
        let url = URL(string: "https://updates.pyrolyse.it/Fluor/rls_nts/update_\(version).html")
        return url
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundleVersion = getBundleVersion()
        versionLabel.stringValue = "Version \(bundleVersion.version) build \(bundleVersion.build)"
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        [iconView, webpageButton, twitterButton, githubButton].forEach {
            guard let view = $0 as? NSView else { return }
            view.wantsLayer = true
            view.centerLayerAnchor()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
//        self.popIconView()
//        self.popButton(self.webpageButton, withOffset: 0)
//        self.popButton(self.twitterButton, withOffset: 0.25)
//        self.popButton(self.githubButton, withOffset: 0.5)
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
    
    private func checkReleaseNotesAvailable() {
        guard let url = self.releaseNotesURL else { return }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
        req.httpMethod = "HEAD"
        let session = URLSession(configuration: .ephemeral)
        session.dataTask(with: req) { [unowned self] (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    self.hasReleaseNotes = resp.statusCode == 200
                }
            } else {
                DispatchQueue.main.async {
                    self.hasReleaseNotes = false
                    NSLog("No available release notes.")
                }
            }
        }
    }
    
    private func popIconView() {
        guard let layer = self.iconView.layer?.model() else { return }
        
        let groupAnimationAnimation = CAAnimationGroup()
        groupAnimationAnimation.duration = 0.970313
        groupAnimationAnimation.fillMode = kCAFillModeForwards
        groupAnimationAnimation.isRemovedOnCompletion = false
        groupAnimationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Group Animation Animations
        //
        // transform.scale
        //
        let transformScaleAnimation = CASpringAnimation()
        transformScaleAnimation.duration = 0.9703
        transformScaleAnimation.fillMode = kCAFillModeForwards
        transformScaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transformScaleAnimation.keyPath = "transform.scale"
        transformScaleAnimation.toValue = 1
        transformScaleAnimation.fromValue = 0
        transformScaleAnimation.stiffness = 200
        transformScaleAnimation.damping = 10
        transformScaleAnimation.mass = 0.7
        transformScaleAnimation.initialVelocity = 7.5
        // transform.rotation.z
        //
        let transformRotationZAnimation = CABasicAnimation()
        transformRotationZAnimation.duration = 0.9703
        transformRotationZAnimation.fillMode = kCAFillModeForwards
        transformRotationZAnimation.isRemovedOnCompletion = false
        transformRotationZAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transformRotationZAnimation.keyPath = "transform.rotation.z"
        transformRotationZAnimation.toValue = CGFloat.pi * 2
        groupAnimationAnimation.animations = [ transformScaleAnimation, transformRotationZAnimation ]
        
        layer.add(groupAnimationAnimation, forKey: "groupAnimationAnimation")
    }
    
    private func popButton(_ button: NSButton, withOffset offset: TimeInterval) {
        guard let layer = button.layer?.model() else { return }
        
        let transformScaleAnimation = CASpringAnimation()
        transformScaleAnimation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + offset
        transformScaleAnimation.duration = 0.99321
        transformScaleAnimation.fillMode = kCAFillModeForwards
        transformScaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transformScaleAnimation.keyPath = "transform.scale"
        transformScaleAnimation.fromValue = 0
        transformScaleAnimation.toValue = 1
        transformScaleAnimation.stiffness = 200
        transformScaleAnimation.damping = 10
        transformScaleAnimation.mass = 0.7
        transformScaleAnimation.initialVelocity = 4
        
        layer.add(transformScaleAnimation, forKey: "transformScaleAnimation")
    }
}
