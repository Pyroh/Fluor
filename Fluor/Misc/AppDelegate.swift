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
        ValueTransformer.setValueTransformer(RuleValueTransformer(), forName: NSValueTransformerName("RuleValueTransformer"))
        if !AXIsProcessTrusted() && !BehaviorManager.default.hasAlreadyAnsweredAccessibility() {
            let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
            AXIsProcessTrustedWithOptions(options)
            BehaviorManager.default.answeredAccessibility()
        }
    }
}


