//
//  AboutWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 04/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {
    @IBOutlet weak var versionLabel: NSTextField!
    
    private var releaseNotesController: ReleaseNotesWindowController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        let bundleVersion = getBundleVersion()
        versionLabel.stringValue = "Version \(bundleVersion.version) build \(bundleVersion.build)"
    }
    
    private func getBundleVersion() -> (version: String, build: String) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        return (version, build)
    }
    
    
    /// Show the application's release notes.
    ///
    /// - Parameter sender: The object that sent the action.
    @IBAction func showReleaseNotes(_ sender: Any) {
        if releaseNotesController == nil {
            releaseNotesController = ReleaseNotesWindowController(windowNibName: NSNib.Name(rawValue: "ReleaseNotesWindowController"))
        }
        releaseNotesController?.showWindow(nil)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        window?.close()
    }
}
