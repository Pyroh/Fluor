//
//  RulesEditorWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 04/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class RulesTableItem: NSObject {
    let id: String
    let url: URL
    let icon: NSImage
    let name: String
    var behavior: Int {
        didSet {
            let info = StatusMenuController.behaviorDidChangeUserInfoConstructor(id: id, url: url, behavior: AppBehavior(rawValue: behavior + 1)!)
            let not = Notification(name: Notification.Name.BehaviorDidChangeForApp, object: self, userInfo: info)
            NotificationCenter.default.post(not)
        }
    }
    
    init(id: String, url: URL, icon: NSImage, name: String, behavior: Int) {
        self.id = id
        self.url = url
        self.icon = icon
        self.name = name
        self.behavior = behavior
    }
}

class RulesEditorWindowController: NSWindowController, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    
    private var rulesArray = [RulesTableItem]()

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.setFrameAutosaveName("EditRulesWindowAutosaveName")
    }
    
    func loadData() {
        loadRules()
        tableView.reloadData()
    }
    
    private func loadRules() {
        var rules = BehaviorManager.default.retrieveRules()
        rules.sort { $0.name < $1.name }
        rulesArray = rules
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rulesArray.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return rulesArray[row]
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
        if !openPanel.urls.isEmpty { loadData() }
    }
    
    @IBAction func removeRule(_ sender: AnyObject) {
        let indexes = tableView.selectedRowIndexes
        indexes.forEach { (index) in
            let item = rulesArray[index]
            BehaviorManager.default.setBehaviorForApp(id: item.id, behavior: .infered, url: item.url)
        }
        if !indexes.isEmpty { loadData() }
    }
}
