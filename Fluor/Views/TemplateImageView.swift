//
//  TemplateImageView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 07/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

@IBDesignable
class TemplateImageView: NSImageView {
    private var bakedImage: NSImage?
    
    @IBInspectable var controlTint: NSColor = NSColor.keyboardFocusIndicatorColor {
        didSet {
            self.bakeImage()
            self.setNeedsDisplay()
        }
    }
    
    override var bounds: NSRect { didSet { self.bakeImage() } }
    override var frame: NSRect { didSet { self.bakeImage() } }
    
    override func draw(_ dirtyRect: NSRect) {
        if let image = self.image, image.isTemplate {
            if self.bakedImage == nil { self.bakeImage() }
            bakedImage!.draw(in: self.bounds)
        } else {
            super.draw(dirtyRect)
        }
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return false
    }
    
    override var acceptsTouchEvents: Bool {
        get { return false }
        set {} 
    }
    
    private func bakeImage() {
        guard let image = self.image else {
            bakedImage = nil
            return
        }
        let baked = image.copy() as! NSImage
        baked.size = self.bounds.size
        baked.lockFocus()
        controlTint.set()
        bounds.fill(using: .sourceAtop)
        baked.unlockFocus()
        self.bakedImage = baked
    }
}
