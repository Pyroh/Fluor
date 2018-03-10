//
//  RunningAppWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 22/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

final class RunningAppWindowController: NSWindowController, StoryboardInstantiable {
    static let storyboardName: NSStoryboard.Name = .runningApps
    
    @IBAction func filterAppList(_ sender: NSSearchField) {
        let searchString = sender.stringValue
        if searchString != "" {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchString)
            (self.contentViewController as? RunningAppsViewController)?.searchPredicate = predicate
        } else {
            (self.contentViewController as? RunningAppsViewController)?.searchPredicate = nil
        }
    }
}
