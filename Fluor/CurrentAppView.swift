//
//  CurrentAppView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

enum AppBehavior: Int {
    case infered
    case apple
    case other
    case negate
}

class CurrentAppView: NSView {
    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var behaviorSegment: NSSegmentedControl!
    
    func setCurrent(app: NSRunningApplication, behavior: AppBehavior) {
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
        appIconView.image = app.icon
        if let name = app.localizedName {
            appNameLabel.stringValue = name
        } else {
            appNameLabel.stringValue = "An app"
        }
    }
    
    func enabled(_ flag: Bool) {
        let controls = [appIconView, appNameLabel, behaviorSegment] as [NSControl]
        controls.forEach {
            $0.isEnabled = flag
        }
    }
    
    @IBAction func behaviorChanged(_ sender: NSSegmentedControl) {
        Swift.print(sender.selectedSegment)
    }
}
