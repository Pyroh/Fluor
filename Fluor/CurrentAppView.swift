//
//  CurrentAppView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa


class CurrentAppView: NSView {
    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var behaviorSegment: NSSegmentedControl!
    
    private var currentApp: NSRunningApplication?
    
    
    /// Change the current running application presented by the view.
    ///
    /// - parameter app:      The running application.
    /// - parameter behavior: The behavior for the application. Either from the rules collection or infered if none.
    func setCurrent(app: NSRunningApplication, behavior: AppBehavior) {
        currentApp = app
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
        appIconView.image = app.icon
        if let name = app.localizedName {
            appNameLabel.stringValue = name
        } else {
            appNameLabel.stringValue = "An app"
        }
    }
    
    
    /// Update the current behavior for the current running application.
    ///
    /// - parameter behavior: The new beavior for the application.
    func updateBehaviorForCurrentApp(_ behavior: AppBehavior) {
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
    }
    
    
    /// Enable or disable the entire view.
    ///
    /// - parameter flag: The enabled state of the view.
    func enabled(_ flag: Bool) {
        let controls = [appIconView, appNameLabel, behaviorSegment] as [NSControl]
        controls.forEach {
            $0.isEnabled = flag
        }
    }
    
    
    /// Change the behavior for the current running application.
    /// It makes sure the behavior manager gets notfified of this change.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func behaviorChanged(_ sender: NSSegmentedControl) {
        if let behavior = AppBehavior(rawValue: sender.selectedSegment) {
            let userInfo = StatusMenuController.behaviorDidChangeUserInfoConstructor(id: currentApp!.bundleIdentifier!, url: currentApp!.bundleURL!, behavior: behavior)
            let not = Notification(name: Notification.Name.BehaviorDidChangeForApp, object: self, userInfo: userInfo)
            NotificationCenter.default.post(not)
        }
    }
}
