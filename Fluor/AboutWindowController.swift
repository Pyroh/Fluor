//
//  AboutWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 04/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.styleMask.formUnion(.fullSizeContentView)
        window?.titleVisibility = .hidden
        window?.setFrameAutosaveName("AboutWindowAutosaveName")
    }
    
}
