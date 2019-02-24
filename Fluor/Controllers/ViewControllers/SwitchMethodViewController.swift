//
//  SwitchModeViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 28/05/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class SwitchMethodViewController: NSViewController, MenuControlPoster, SwitchMethodDidChangePoster {
    @IBOutlet weak var methodSegmentedControl: NSSegmentedControl!
    @objc private dynamic var switchCapable: Bool = true
    
    @IBAction func changeSwitchMethod(_ sender: NSSegmentedControl) {
        guard let method = SwitchMethod(rawValue: sender.selectedSegment) else { return }
        self.postSwitchMethodDidChangeNotification(method: method)
    }
    
    @IBAction func askAccessibilityPersmission(_ sender: Any) {
        self.postMenuNeedsToCloseNotification()
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
        AXIsProcessTrustedWithOptions(options)
    }
}
