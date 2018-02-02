//
//  RulesEditorViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 24/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class RulesEditorViewController: NSViewController, BehaviorDidChangeHandler {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var itemsArrayController: NSArrayController!
    @IBOutlet weak var contentActionSegmentedControl: NSSegmentedControl!
    
    @objc dynamic var rulesSet = Set<RuleItem>()
    
    @objc dynamic var searchPredicate: NSPredicate?
    @objc dynamic var sortDescriptors: [NSSortDescriptor] = [.init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
    
    private var orchestrator: TableViewContentOrchestrator<RuleItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startObservingBehaviorDidChange()
        itemsArrayController.addObserver(self, forKeyPath: "canRemove", options: [], context: nil)
        itemsArrayController.addObserver(self, forKeyPath: "canAdd", options: [], context: nil)
        
        self.rulesSet = Set<RuleItem>(BehaviorManager.default.retrieveRules())
        
        self.orchestrator = TableViewContentOrchestrator(tableView: tableView, arrayController: itemsArrayController)
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
        guard let userInfo = notification.userInfo as? [String: Any], userInfo["source"] as? NotificationSource != .rulesWindow else { return }
        guard let appId = userInfo["id"] as? String, let appBehavior = userInfo["behavior"] as? AppBehavior, let appURL = userInfo["url"] as? URL else { return }
        if let item = rulesSet.first(where: { $0.id == appId }) {
            if case .inferred = appBehavior {
                itemsArrayController.removeObject(item)
            } else {
                item.behavior = appBehavior
            }
        } else if appBehavior != .inferred {
            let appPath = appURL.path
            let appIcon = NSWorkspace.shared.icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: appBehavior, kind: .rule)
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
        let items = openPanel.urls.map { (appURL) -> RuleItem in
            let appBundle = Bundle(url: appURL)!
            let appId = appBundle.bundleIdentifier!
            let appPath = appURL.path
            let appIcon = NSWorkspace.shared.icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            BehaviorManager.default.setBehaviorForApp(id: appId, behavior: .apple, url: appURL)
            return RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: AppBehavior.apple, kind: .rule)
        }
        rulesSet.formUnion(items)
    }
    
    /// Remove a rule for a given application.
    ///
    /// - parameter sender: The object that sent the action.
    func removeRule() {
        guard let items = itemsArrayController.selectedObjects as? [RuleItem] else { return }
        items.forEach { (item) in
            BehaviorManager.default.setBehaviorForApp(id: item.id, behavior: .inferred, url: item.url)
            let info = BehaviorController.behaviorDidChangeUserInfoConstructor(id: item.id, url: item.url, behavior: .inferred)
            let not = Notification(name: .BehaviorDidChangeForApp, object: self, userInfo: info)
            NotificationCenter.default.post(not)
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
