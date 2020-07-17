//
//  AppDelegate.swift
//
//  Fluor
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
        if !AXIsProcessTrusted() && !AppManager.default.hasAlreadyAnsweredAccessibility {
            let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
            AXIsProcessTrustedWithOptions(options)
            AppManager.default.hasAlreadyAnsweredAccessibility = true
        }
        
        if AppManager.default.lastRunVersion != self.getBundleVersion() {
            AppManager.default.lastRunVersion = self.getBundleVersion()
            let rnctrl = ReleaseNotesWindowController.instantiate()
            rnctrl.window?.orderFrontRegardless()
        }
        
        UserNotificationHelper.askUserAtLaunch()
        
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


