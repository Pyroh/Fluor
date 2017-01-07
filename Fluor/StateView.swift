//
//  StatusView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class StateView: NSView {
    @IBOutlet weak var stateSelector: NSSegmentedControl!
    
    /// Set the current default keyboard state.
    ///
    /// - parameter flag: The keyboard state.
    func setState(flag: KeyboardState) {
        switch flag {
        case .apple:
            stateSelector.setSelected(true, forSegment: 0)
        default:
            stateSelector.setSelected(true, forSegment: 1)
        }
    }
    
    
    /// Change the current keyboard state.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func changeState(_ sender: NSSegmentedControl) {
        let state = KeyboardState(rawValue: sender.selectedSegment)!
        let userInfo = ["state": state]
        let not = Notification(name: Notification.Name.StateViewDidChangeState, object: self, userInfo: userInfo)
        NotificationCenter.default.post(not)
    }
}
