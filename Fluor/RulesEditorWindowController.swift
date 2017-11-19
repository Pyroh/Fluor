//
//  RulesEditorWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 04/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class RulesEditorWindowController: NSWindowController, BehaviorDidChangeHandler {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var rulesArrayController: NSArrayController!
    @IBOutlet weak var contentActionSegmentedControl: NSSegmentedControl!
    
    @objc dynamic var rulesArray = [RuleItem]()
    @objc dynamic var rulesCount: Int = 0
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        
        startObservingBehaviorDidChange()
        rulesArrayController.addObserver(self, forKeyPath: "canRemove", options: [], context: nil)
        rulesArrayController.addObserver(self, forKeyPath: "canAdd", options: [], context: nil)
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        rulesArrayController.sortDescriptors = [sortDescriptor]
        
        rulesArray = BehaviorManager.default.retrieveRules()
    }
    
    deinit {
        stopObservingBehaviorDidChange()
        rulesArrayController.removeObserver(self, forKeyPath: "canRemove")
        rulesArrayController.removeObserver(self, forKeyPath: "canAdd")
    }
    
    /// Called when a rule change for an application.
    ///
    /// - parameter notification: The notification.
    func behaviorDidChangeForApp(notification: Notification) {
        if let obj = notification.object as? RuleItem, case .runningApp = obj.kind { return }
        guard (notification.object as AnyObject) !== self else { return }
        guard let userInfo = notification.userInfo as? [String: Any], let appId = userInfo["id"] as? String, let appBehavior = userInfo["behavior"] as? AppBehavior, let appURL = userInfo["url"] as? URL else { return }
        if let index = rulesArray.index(where: { $0.id == appId }) {
            if case .inferred = appBehavior {
                rulesArray.remove(at: index)
            } else {
                rulesArray[index].behavior = appBehavior
            }
        } else {
            let appPath = appURL.path
            let appIcon = NSWorkspace.shared.icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: appBehavior, kind: .rule)
            rulesArray.append(item)
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
        openPanel.urls.forEach { (appURL) in
            let appBundle = Bundle(url: appURL)!
            let appId = appBundle.bundleIdentifier!
            let appPath = appURL.path
            let appIcon = NSWorkspace.shared.icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            BehaviorManager.default.setBehaviorForApp(id: appId, behavior: .apple, url: appURL)
            let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: AppBehavior.apple, kind: .rule)
            rulesArray.append(item)
        }
    }
    
    /// Remove a rule for a given application.
    ///
    /// - parameter sender: The object that sent the action.
    func removeRule() {
        guard let items = rulesArrayController.selectedObjects as? [RuleItem] else { return }
        items.forEach { (item) in
            BehaviorManager.default.setBehaviorForApp(id: item.id, behavior: .inferred, url: item.url)
            let index = rulesArray.index(of: item)!
            let info = BehaviorController.behaviorDidChangeUserInfoConstructor(id: item.id, url: item.url, behavior: .inferred)
            let not = Notification(name: .BehaviorDidChangeForApp, object: self, userInfo: info)
            NotificationCenter.default.post(not)
            rulesArray.remove(at: index)
        }
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
        guard (object as? NSArrayController) ==  rulesArrayController, let keyPath = keyPath else { return }
        switch keyPath {
        case "canAdd":
            contentActionSegmentedControl.setEnabled(rulesArrayController.canAdd, forSegment: 0)
        case "canRemove":
            contentActionSegmentedControl.setEnabled(rulesArrayController.canRemove, forSegment: 1)
        default:
            return
        }
    }
}
