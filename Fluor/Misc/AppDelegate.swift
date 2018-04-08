//
//  AppDelegate.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if RELEASE
            PFMoveToApplicationsFolderIfNecessary()
        #endif
        HAHelper.default.initManager()
        HAHelper.default.eventFluorStarted()
        
        ValueTransformer.setValueTransformer(RuleValueTransformer(), forName: NSValueTransformerName("RuleValueTransformer"))
        
        // Check accessibility
        if !AXIsProcessTrusted() && !BehaviorManager.default.hasAlreadyAnsweredAccessibility() {
            let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
            AXIsProcessTrustedWithOptions(options)
            BehaviorManager.default.answeredAccessibility()
        } else if AXIsProcessTrusted() {
            HAHelper.default.eventUsesAccessibility()
        } else {
            HAHelper.default.eventDoesntUseAccessibility()
        }
    }
}


