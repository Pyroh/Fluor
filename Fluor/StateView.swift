//
//  StatusView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class StateView: NSView {
    @IBOutlet weak var button: NSButton!
    
    func setState(flag: Bool) {
        button.state = flag ? NSOnState : NSOffState
        button.title = flag ? "Apple Mode" : "Other Mode"
    }
    
    @IBAction func changeState(_ sender: NSButton) {
        let state = button.state == NSOnState
        let userInfo = ["state": state]
        let not = Notification(name: Notification.Name.StateViewDidChangeState, object: self, userInfo: userInfo)
        NotificationCenter.default.post(not)
    }
}
