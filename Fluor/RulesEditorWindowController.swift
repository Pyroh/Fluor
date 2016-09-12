//
//  RulesEditorWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 04/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class RulesEditorWindowController: NSWindowController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var rulesArrayController: NSArrayController!
    
    dynamic var rulesArray = [RuleItem]()

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.formUnion(.nonactivatingPanel)
        window?.setFrameAutosaveName("EditRulesWindowAutosaveName")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        rulesArrayController.sortDescriptors = [sortDescriptor]
    }
    
    func loadRules() {
        rulesArray = BehaviorManager.default.retrieveRules()
    }
    
    @IBAction func addRule(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = ["com.apple.bundle"]
        openPanel.canChooseDirectories = false
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.runModal()
        openPanel.urls.forEach { (appURL) in
            let appBundle = Bundle(url: appURL)!
            let appId = appBundle.bundleIdentifier!
            let appPath = appURL.path
            let appIcon = NSWorkspace.shared().icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            BehaviorManager.default.setBehaviorForApp(id: appId, behavior: .apple, url: appURL)
            let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: AppBehavior.apple.rawValue)
            rulesArray.append(item)
        }
    }
    
    @IBAction func removeRule(_ sender: AnyObject) {
        let items = rulesArrayController.selectedObjects as! [RuleItem]
        items.forEach { (item) in
            BehaviorManager.default.setBehaviorForApp(id: item.id, behavior: .infered, url: item.url)
            let index = rulesArray.index(of: item)!
            rulesArray.remove(at: index)
        }
    }
}
