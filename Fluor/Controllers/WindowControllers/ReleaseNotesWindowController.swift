//
//  ReleaseNotesWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 12/02/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class ReleaseNotesWindowController: NSWindowController {
    @IBOutlet var textView: NSTextView!
    @objc dynamic private var contentURL: URL?

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        contentURL = Bundle.main.url(forResource: "ReleaseNotes", withExtension: "rtf")
        
        textView.isEditable = false
    }
}
