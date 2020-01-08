//
//  LinkButton.swift
//  Fluor
//
//  Created by Pierre TACCHI on 26/03/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

@IBDesignable
class LinkButton: NSButton {
    @IBInspectable var growsOnHover: Bool = true
    @IBInspectable var growFactor: CGFloat = 1.15
    
    override func layout() {
        super.layout()
        self.centerLayerAnchor()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        self.trackingAreas.forEach(self.removeTrackingArea(_:))
        let trackingArea = NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        self.addCursorRect(self.bounds, cursor: .pointingHand)
    }
    
    // Thanks to Kite Compositor (kiteapp.co)
    override func mouseEntered(with event: NSEvent) {
        guard self.growsOnHover, let layer = self.layer else { return }
        
        let transformScaleAnimation = CASpringAnimation()
        
        transformScaleAnimation.fillMode = kCAFillModeForwards
        transformScaleAnimation.duration = 0.99321
        transformScaleAnimation.isRemovedOnCompletion = false
        transformScaleAnimation.keyPath = "transform.scale"
        transformScaleAnimation.toValue = self.growFactor
        transformScaleAnimation.stiffness = 200
        transformScaleAnimation.damping = 10
        transformScaleAnimation.mass = 0.7
        transformScaleAnimation.initialVelocity = 4
        
        layer.add(transformScaleAnimation, forKey: "growAnimation")
    }
    
    // Thanks to Kite Compositor (kiteapp.co)
    override func mouseExited(with event: NSEvent) {
        guard self.growsOnHover, let layer = self.layer else { return }
        
        let transformScaleAnimation1 = CASpringAnimation()
        
        transformScaleAnimation1.duration = 0.99321
        transformScaleAnimation1.fillMode = kCAFillModeForwards
        transformScaleAnimation1.isRemovedOnCompletion = false
        transformScaleAnimation1.keyPath = "transform.scale"
        transformScaleAnimation1.toValue = 1
        transformScaleAnimation1.stiffness = 200
        transformScaleAnimation1.damping = 10
        transformScaleAnimation1.mass = 0.7
        transformScaleAnimation1.initialVelocity = 4
        
        layer.add(transformScaleAnimation1, forKey: "shrinkAnimation")
    }
}
