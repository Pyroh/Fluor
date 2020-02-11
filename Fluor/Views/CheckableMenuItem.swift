//
//  CheckableMenuItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 01/08/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class CheckableMenuItem: NSMenuItem {
    private static let eraserImage = NSImage(size: NSSize(width: 16.0, height: 16.0))
    
    private var onStateImageShadow: NSImage?
    private var offStateImageShadow: NSImage?
    private var mixedStateImageShadow: NSImage?
    
    override var onStateImage: NSImage! {
        didSet {
            guard self.onStateImage != Self.eraserImage else { return }
            self.onStateImageShadow = self.onStateImage
            self.onStateImage = Self.eraserImage
        }
    }
    
    override var state: NSControl.StateValue {
        didSet {
            self.adaptImageToState()
        }
    }
    
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
        self.setup()
        self.adaptImageToState()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.setup()
        self.adaptImageToState()
    }
    
    private func setup() {
        self.onStateImageShadow = self.onStateImage
        self.offStateImageShadow = self.offStateImage
        self.mixedStateImageShadow = self.mixedStateImage
        self.onStateImage = Self.eraserImage
        self.offStateImage = Self.eraserImage
        self.mixedStateImage = Self.eraserImage
    }
    
    private func adaptImageToState() {
        switch self.state {
        case .on:
            self.image = self.onStateImageShadow
        case .off:
            self.image = self.offStateImageShadow
        default:
            self.image = self.mixedStateImageShadow
        }
    }
}
