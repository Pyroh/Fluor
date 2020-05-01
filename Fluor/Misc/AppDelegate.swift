//
//  AppDelegate.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let statusMenuController: StatusMenuController = .init()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if RELEASE
            PFMoveToApplicationsFolderIfNecessary()
        #endif
        
        ValueTransformer.setValueTransformer(RuleValueTransformer(), forName: NSValueTransformerName("RuleValueTransformer"))
        
        // Check accessibility
        if !AXIsProcessTrusted() && !BehaviorManager.default.hasAlreadyAnsweredAccessibility {
            let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
            AXIsProcessTrustedWithOptions(options)
            BehaviorManager.default.hasAlreadyAnsweredAccessibility = true
        }
        
        if BehaviorManager.default.lastRunVersion != self.getBundleVersion() {
            BehaviorManager.default.lastRunVersion = self.getBundleVersion()
            let rnctrl = ReleaseNotesWindowController.instantiate()
            rnctrl.window?.orderFrontRegardless()
        }
        
        self.loadMainMenu()
    }
    
    private func loadMainMenu() {
        let nib = NSNib(nibNamed: "MainMenu", bundle: nil)
        nib?.instantiate(withOwner: self.statusMenuController, topLevelObjects: nil)
        
        NSApp.hide(self)
    }
    
    private func getBundleVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    func windowWillClose(_ notification: Notification) {
        self.loadMainMenu()
    }
}


