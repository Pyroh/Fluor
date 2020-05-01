//
//  CheckableMenuItem.swift
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
