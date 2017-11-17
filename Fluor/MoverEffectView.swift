//
//  MoverEffectView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 07/10/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class MoverEffectView: NSVisualEffectView {
    override func mouseDown(with event: NSEvent) {
        guard let window = self.window else { return }
        window.performDrag(with: event)
    }
}
