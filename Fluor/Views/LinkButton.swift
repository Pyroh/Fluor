//
//  LinkButton.swift
//  Fluor
//
//  Created by Pierre TACCHI on 07/05/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved.
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
