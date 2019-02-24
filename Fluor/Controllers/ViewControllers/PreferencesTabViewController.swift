//
//  PreferencesTabViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 17/11/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController, TriggerSectionVisibilityDidChangePoster, SwitchMethodDidChangePoster {
    @IBAction func changeTriggerSectionVisibility(_ sender: NSButton) {
        let visible = sender.state == .off
        if !visible {
            self.postSwitchMethodDidChangeNotification(method: .window)
            BehaviorManager.default.switchMethod = .window            
        }
        self.postTriggerSectionVisibilityDidChange(visible: visible)
    }
}
