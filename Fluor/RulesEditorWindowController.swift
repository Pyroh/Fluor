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
    
    dynamic var rulesArray = [RulesTableItem]()

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.formUnion(.nonactivatingPanel)
        window?.setFrameAutosaveName("EditRulesWindowAutosaveName")
    }
    
    func loadRules() {
        let rules = BehaviorManager.default.retrieveRules()
        rulesArray = rules.sorted { $0.name < $1.name }
    }
    
    @IBAction func addRule(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = ["com.apple.bundle"]
        openPanel.canChooseDirectories = false
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.runModal()
        openPanel.urls.forEach { (url) in
            let id = Bundle(url: url)!.bundleIdentifier!
            BehaviorManager.default.setBehaviorForApp(id: id, behavior: .apple, url: url)
        }
        if !openPanel.urls.isEmpty { loadRules() }
    }
    
    @IBAction func removeRule(_ sender: AnyObject) {
        let indexes = tableView.selectedRowIndexes
        indexes.forEach { (index) in
            let item = rulesArray[index]
            BehaviorManager.default.setBehaviorForApp(id: item.id, behavior: .infered, url: item.url)
        }
        if !indexes.isEmpty { loadRules() }
    }
}
