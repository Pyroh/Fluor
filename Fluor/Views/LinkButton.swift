//
//  LinkButton.swift
//  Fluor
//
//  Created by Pierre TACCHI on 26/03/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class LinkButton: NSButton {
    override func resetCursorRects() {
        super.resetCursorRects()
        self.addCursorRect(self.bounds, cursor: .pointingHand)
    }
    
    override func mouseEntered(with event: NSEvent) {
        Swift.print(event)
    }
}
