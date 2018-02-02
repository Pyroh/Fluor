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
    
    @objc dynamic var searchPredicate: NSPredicate?
    
    override func windowDidLoad() {
        contentViewController?.bind(.init("searchPredicate"), to: self, withKeyPath: "searchPredicate", options: nil)
    }
}
