//
//  SelectableBox.swift
//  Fluor
//
//  Created by Pierre TACCHI on 24/02/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved
//

import Cocoa

class SelectableView: NSBox {
    private var isClicked: Bool = false {
        didSet { self.updateState() }
    }
    
    private var isHighlighted: Bool = false {
        didSet { self.updateState() }
    }
    
    private var highlightedColor: NSColor {
        .controlColor
    }
    
    private var clickedColor: NSColor {
        .selectedControlColor
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    override func updateTrackingAreas() {
        self.trackingAreas.forEach(self.removeTrackingArea(_:))
        self.addTrackingArea(.init(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited, .enabledDuringMouseDrag], owner: self, userInfo: nil))
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard NSEvent.pressedMouseButtons == 0 || self.isClicked else { return }
        self.isHighlighted = true
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.isHighlighted = false
    }
    
    override func mouseDown(with event: NSEvent) {
        self.isClicked = true
    }
    
    override func mouseUp(with event: NSEvent) {
        self.isClicked = false
        if self.isHighlighted {
            
        }
    }
    
    private func updateState() {
        switch (self.isHighlighted, self.isClicked) {
        case (false, true):
            self.fillColor = .clear
        case (_, true):
            self.fillColor = self.clickedColor
        case (true, _):
            if self.fillColor == self.clickedColor {
                self.fillColor = self.highlightedColor
            } else {
                self.animator().fillColor = self.highlightedColor
            }
        default:
            if self.fillColor == self.highlightedColor {
                self.animator().fillColor = .clear
            } else {
                self.fillColor = .clear
            }
        }
    }
    
    private func handleClick() {
        
    }
}
