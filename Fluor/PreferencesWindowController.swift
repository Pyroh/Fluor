//
//  PreferencesWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 05/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.setFrameAutosaveName("PreferencesWindowAutosaveName")
    }
}
