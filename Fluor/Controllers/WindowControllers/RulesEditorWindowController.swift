//
//  RulesEditorWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 04/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

final class RulesEditorWindowController: NSWindowController, StoryboardInstantiable {
    static let storyboardName: NSStoryboard.Name = .rulesEditor
    
    @objc dynamic var searchPredicate: NSPredicate?
    
    override func windowDidLoad() {
        contentViewController?.bind(.init("searchPredicate"), to: self, withKeyPath: "searchPredicate", options: nil)
    }
}
