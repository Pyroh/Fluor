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
        
        // Check Metal is available
        if self.isMetalAvailable() {
            HAHelper.default.eventMetalIsAvailable()
        }
        
        if BehaviorManager.default.lastRunVersion != self.getBundleVersion() {
            // Do something on new version.
        }
    }
    
    private func getBundleVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        return "\(version)+\(build)"
    }
    
    private func isMetalAvailable() -> Bool {
        return MTLCopyAllDevices().count > 0
    }
}


