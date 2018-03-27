//
//  PreferencesWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 05/02/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

final class PreferencesWindowController: NSWindowController, StoryboardInstantiable {
    static var storyboardName: NSStoryboard.Name = .preferences
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let toolbar = window?.toolbar
        toolbar?.insertItem(withItemIdentifier: .flexibleSpace, at: 2)
    }
}
