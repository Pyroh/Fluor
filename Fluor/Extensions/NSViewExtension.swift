//
//  NSViewExtension.swift
//  Fluor
//
//  Created by Pierre TACCHI on 09/03/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

extension NSView {
    var nameOfVibrantAncestor: NSAppearance.Name? {
        get {
            return self.appearance?.allowsVibrancy == true ? self.appearance?.name : superview?.nameOfVibrantAncestor
        }
    }
    
    func centerLayerAnchor() {
        let x = self.frame.midX
        let y = self.frame.midY
        
        self.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer?.position = CGPoint(x: x, y: y)
        self.layer?.contentsGravity = kCAGravityCenter
    }
}
