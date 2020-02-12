//
//  CurrentAppView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class CurrentAppViewController: NSViewController, BehaviorDidChangeObserver, ActiveApplicationDidChangeObserver {

    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var behaviorSegment: NSSegmentedControl!
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    
    internal var currentSwitchMethod = SwitchMethod.window
    
    private var currentAppID: String = ""
    private var currentAppURL: URL?
    
    deinit {
        self.stopObservingBehaviorDidChange()
        self.stopObservingActiveApplicationDidChange()
    }
    
    override func viewDidLoad() {
        self.startObservingBehaviorDidChange()
        self.startObservingActiveApplicationDidChange()
        
        if let currentApp = NSWorkspace.shared.frontmostApplication {
            self.setCurrent(app: currentApp)
        }
    }
    
    func shrinkView() {
        self.currentSwitchMethod = .key
        var newFrame = self.view.frame
        newFrame.size.height = 32
        self.imageConstraint.constant = 24
        self.behaviorSegment.isHidden = true
        self.view.setFrameSize(newFrame.size)
    }
    
    func expandView() {
        self.currentSwitchMethod = .window
        var newFrame = self.view.frame
        newFrame.size.height = 72
        self.imageConstraint.constant = 64
        self.behaviorSegment.isHidden = false
        self.view.setFrameSize(newFrame.size)
    }
    
    /// Change the behavior for the current running application.
    /// It makes sure the behavior manager gets notfified of this change.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func behaviorChanged(_ sender: NSSegmentedControl) {
        guard let behavior = AppBehavior(rawValue: sender.selectedSegment), let url = self.currentAppURL else { return }
        BehaviorManager.default.propagate(behavior: behavior, forApp: self.currentAppID, at: url, from: .mainMenu)
    }
    
    // MARK: - Private functions
    
    /// Change the current running application presented by the view.
    ///
    /// - parameter app:      The running application.
    /// - parameter behavior: The behavior for the application. Either from the rules collection or infered if none.
    private func setCurrent(app: NSRunningApplication) {
        guard let id = app.bundleIdentifier ?? app.executableURL?.lastPathComponent,
            let url = app.bundleURL ?? app.executableURL else { return }
        
        self.currentAppID = id
        self.currentAppURL = url
        let behavior = BehaviorManager.default.behaviorForApp(id: id)
        
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
        appIconView.image = app.icon
        if let name = app.localizedName {
            appNameLabel.stringValue = name
        } else {
            appNameLabel.stringValue = "An app"
        }
    }
    
    // MARK: - ActiveApplicationDidChangeObserver
    
    func activeApplicationDidChangw(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
        self.setCurrent(app: app)
    }
    
    // MARK: - BehaviorDidChangeObserver
    
    func behaviorDidChangeForApp(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any], userInfo["source"] as? NotificationSource != .mainMenu else { return }
        guard let id = userInfo["id"] as? String, self.currentAppID == id, let behavior = userInfo["behavior"] as? AppBehavior else { return }
        
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
    }
}
