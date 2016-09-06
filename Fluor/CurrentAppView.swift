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
    
    func updateBehaviorForCurrentApp(_ behavior: AppBehavior) {
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
    }
    
    func enabled(_ flag: Bool) {
        let controls = [appIconView, appNameLabel, behaviorSegment] as [NSControl]
        controls.forEach {
            $0.isEnabled = flag
        }
    }
    
    @IBAction func behaviorChanged(_ sender: NSSegmentedControl) {
        if let behavior = AppBehavior(rawValue: sender.selectedSegment) {
            let userInfo = StatusMenuController.behaviorDidChangeUserInfoConstructor(id: currentApp!.bundleIdentifier!, url: currentApp!.bundleURL!, behavior: behavior)
            let not = Notification(name: Notification.Name.BehaviorDidChangeForApp, object: self, userInfo: userInfo)
            NotificationCenter.default.post(not)
        }
    }
}
