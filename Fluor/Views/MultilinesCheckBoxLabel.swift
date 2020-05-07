//
//  MultilinesCheckBoxLabel.swift
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

class MultilinesCheckBoxLabel: NSTextField {
    @IBOutlet weak var checkBox: NSButton!
    
    override var isHighlighted: Bool {
        didSet {
            checkBox.isHighlighted = isHighlighted
        }
    }
    private var isClicked = false
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        self.trackingAreas.forEach(self.removeTrackingArea(_:))
        let trackingArea = NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func mouseDown(with event: NSEvent) {
        isClicked = true
        isHighlighted = true
    }
    
    override func mouseUp(with event: NSEvent) {
        if isHighlighted { checkBox.performClick(self) }
        isClicked = false
    }
    
    override func mouseEntered(with event: NSEvent) {
        if isClicked { isHighlighted = true }
    }
    
    override func mouseExited(with event: NSEvent) {
        if isClicked { isHighlighted = false }
    }
}
