//
//  FirstMouseEventAccepterView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 10/03/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class FirstMouseEventAccepterView: NSView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
