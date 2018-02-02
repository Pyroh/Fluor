//
//  MenuItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 18/12/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class SwitchMenuItem: NSMenuItem {
    override var isEnabled: Bool {
        didSet {
            (self.view as? SwitchView)?.setEnabled(isEnabled)
        }
    }
}

class SwitchView: NSView {
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    func setEnabled(_ flag: Bool) {
        segmentedControl.isEnabled = flag
        label.layer?.opacity = flag ? 1.0 : 0.4
    }
}
