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

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.styleMask.formUnion(.fullSizeContentView)
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        
        let bundleVersion = getBundleVersion()
        versionLabel.stringValue = "Version \(bundleVersion.version) build \(bundleVersion.build)"
    }
    
    private func getBundleVersion() -> (version: String, build: String) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        return (version, build)
    }
}
