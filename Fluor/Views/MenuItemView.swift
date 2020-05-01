//
//  OpaqueView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 01/05/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved.
//

import AppKit

class MenuItemView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        if #available(OSX 10.14, *), isAccessible {
            let darkComponent: CGFloat = 42.0/255
            let lightComponent: CGFloat = 244.0/255
            let component = isDark ? darkComponent : lightComponent
            
            NSColor(calibratedRed: component, green: component, blue: component, alpha: 1).setFill()
            dirtyRect.fill()
        } else {
            super.draw(dirtyRect)
        }
    }
}
