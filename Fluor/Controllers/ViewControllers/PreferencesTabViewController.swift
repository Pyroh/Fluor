//
//  PreferencesTabViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 17/11/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {
    override func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        if let id = tabViewItem?.identifier as? String, "updates_tab" == id {
            self.showBetaAlert()
            return false
        }
        return true
    }
    
    private func showBetaAlert() {
        let alert = NSAlert()
        alert.messageText = "Sorry this feature is not available yet."
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
