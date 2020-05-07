//
//  LinkButton.swift
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
import SmoothOperators

final class LinkButton: NSButton {
    @IBInspectable var url: String?
    private var actualURL: URL? {
        guard let url = url else { return nil }
        return URL(string: url)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupAppearance()
        createAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
        createAction()
    }
    
    private func setupAppearance() {
        isBordered = false
        imagePosition = .noImage
        alternateTitle = title
        
        var attributes = attributedTitle.fontAttributes(in: .init(location: 0, length: attributedTitle.length))
        attributes[.foregroundColor] = NSColor.linkColor
        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        
        let newAttributedTitle = NSAttributedString(string: title, attributes: attributes)
        
        attributedTitle = newAttributedTitle
        attributedAlternateTitle = newAttributedTitle
    }

    private func createAction() {
        target = self
        action = #selector(openURL(_:))
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        self.addCursorRect(self.bounds, cursor: .pointingHand)
    }
    
    @IBAction func openURL(_ sender: Any?){
        guard !!url else { return }
        guard let destinationURL = actualURL else { return assertionFailure("\(self.url!) is not a valid URL.") }
        NSWorkspace.shared.open(destinationURL)
    }
}
