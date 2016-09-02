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
    dynamic var state: Bool = false {
        didSet {
            switchState()
            changeTitleAccordingToState()
        }
    }
    dynamic var appID: String?
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var button: NSButton!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        window.styleMask = NSFullSizeContentViewWindowMask.union(NSTexturedBackgroundWindowMask).union(NSResizableWindowMask)
        window.level = Int(CGWindowLevelForKey(.maximumWindow))
        
        state = getStateAccordingToPreferences()
        button.state = state ? NSOnState : NSOffState
        changeTitleAccordingToState()
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activeAppDidChange(notification:)), name: NSNotification.Name.NSWorkspaceDidActivateApplication, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NSWorkspace.shared().notificationCenter.removeObserver(self)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @objc private func activeAppDidChange(notification: NSNotification) {
        guard let app = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication,
            let id = app.bundleIdentifier else { return }
        appID = id
    }
    
    private func switchState() {
        if state {
            setFnKeysToOtherMode()
        } else {
            setFnKeysToAppleMode()
        }
    }
    
    private func getStateAccordingToPreferences() -> Bool {
        switch getCurrentFnKeyState() {
        case AppleMode:
            return false
        case OtherMode:
            return true
        default:
            assertionFailure()
            return false
        }
    }
    
    private func changeTitleAccordingToState() {
        button.title = state ? "Switch to Apple mode" : "Switch to Other mode"
    }
}

