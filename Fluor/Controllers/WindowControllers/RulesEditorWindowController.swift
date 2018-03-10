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
    
    @IBAction func filterRuleList(_ sender: NSSearchField) {
        let searchString = sender.stringValue
        if searchString != "" {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchString)
            (self.contentViewController as? RulesEditorViewController)?.searchPredicate = predicate
        } else {
            (self.contentViewController as? RulesEditorViewController)?.searchPredicate = nil
        }
    }
}
