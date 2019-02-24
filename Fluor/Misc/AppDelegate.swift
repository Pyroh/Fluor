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
        
        ValueTransformer.setValueTransformer(RuleValueTransformer(), forName: NSValueTransformerName("RuleValueTransformer"))
        
        // Check accessibility
        if !AXIsProcessTrusted() && !BehaviorManager.default.hasAlreadyAnsweredAccessibility {
            let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
            AXIsProcessTrustedWithOptions(options)
            BehaviorManager.default.hasAlreadyAnsweredAccessibility = true
        }
        
        if BehaviorManager.default.lastRunVersion != self.getBundleVersion() {
            // Do something on new version. If needed... It's not needed.
        }
    }
    
    private func getBundleVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        return "\(version)+\(build)"
    }
}


