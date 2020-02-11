//
//  RulesEditorViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 24/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class RulesEditorViewController: NSViewController, BehaviorDidChangeObserver {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var itemsArrayController: NSArrayController!
    @IBOutlet weak var contentActionSegmentedControl: NSSegmentedControl!
    
    @objc dynamic var rulesSet = Set<Rule>()
    
    @objc dynamic var searchPredicate: NSPredicate?
    @objc dynamic var sortDescriptors: [NSSortDescriptor] = [.init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
    
    private var tableContentAnimator: TableViewContentAnimator<Rule>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startObservingBehaviorDidChange()
        itemsArrayController.addObserver(self, forKeyPath: "canRemove", options: [], context: nil)
        itemsArrayController.addObserver(self, forKeyPath: "canAdd", options: [], context: nil)
        
        self.rulesSet = BehaviorManager.default.rules
        
        self.tableContentAnimator = TableViewContentAnimator(tableView: tableView, arrayController: itemsArrayController)
    }
    
    deinit {
        stopObservingBehaviorDidChange()
        itemsArrayController.removeObserver(self, forKeyPath: "canRemove")
        itemsArrayController.removeObserver(self, forKeyPath: "canAdd")
    }
    
    /// Called when a rule change for an application.
    ///
    /// - parameter notification: The notification.
    func behaviorDidChangeForApp(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any], userInfo["source"] as? NotificationSource != .rule else { return }
        guard let id = userInfo["id"] as? String, let behavior = userInfo["behavior"] as? AppBehavior, let url = userInfo["url"] as? URL else { return }
        if let item = rulesSet.first(where: { $0.id == id }) {
            if case .inferred = behavior {
                itemsArrayController.removeObject(item)
            } else {
                item.behavior = behavior
            }
        } else if behavior != .inferred {
            let item = Rule(id: id, url: url, behavior: behavior)
            rulesSet.insert(item)
        }
    }
    
    /// Add a rule for an application.
    func addRule() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = ["com.apple.bundle"]
        openPanel.canChooseDirectories = false
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.runModal()
        let items = openPanel.urls.map { (url) -> Rule in
            let bundle = Bundle(url: url)!
            let id = bundle.bundleIdentifier!
            
            BehaviorManager.default.propagate(behavior: .apple, forApp: id, at: url, from: .rule)
            return Rule(id: id, url: url, behavior: .apple)
        }
        rulesSet.formUnion(items)
    }
    
    /// Remove a rule for a given application.
    func removeRule() {
        guard let items = itemsArrayController.selectedObjects as? [Rule] else { return }
        items.forEach { (item) in
            BehaviorManager.default.propagate(behavior: .inferred, forApp: item.id, at: item.url, from: .rule)
        }
        itemsArrayController.remove(self)
    }
    
    @IBAction func operateRuleCollection(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            self.addRule()
        default:
            self.removeRule()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard (object as? NSArrayController) ==  itemsArrayController, let keyPath = keyPath else { return }
        switch keyPath {
        case "canAdd":
            contentActionSegmentedControl.setEnabled(itemsArrayController.canAdd, forSegment: 0)
        case "canRemove":
            contentActionSegmentedControl.setEnabled(itemsArrayController.canRemove, forSegment: 1)
        default:
            return
        }
    }
}
