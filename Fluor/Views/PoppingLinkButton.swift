//
//  PoppingLinkButton.swift
//   
//  Fluor
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import Cocoa

@IBDesignable
class PoppingLinkButton: NSButton {
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
        
        transformScaleAnimation.fillMode = CAMediaTimingFillMode.forwards
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
        transformScaleAnimation1.fillMode = CAMediaTimingFillMode.forwards
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
