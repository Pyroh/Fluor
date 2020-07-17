//
//  RulesEditorViewController.swift
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
        
        self.rulesSet = AppManager.default.rules
        
        self.tableContentAnimator = TableViewContentAnimator(tableView: tableView, arrayController: itemsArrayController)
    }
    
    deinit {
        stopObservingBehaviorDidChange()
        itemsArrayController.removeObserver(self, forKeyPath: "canRemove")
        itemsArrayController.removeObserver(self, forKeyPath: "canAdd")
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
    
    // MARK: - BehaviorDidChangeObserver
    
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
    
    // MARK: - Private functions
    
    /// Add a rule for an application.
    private func addRule() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = ["com.apple.bundle"]
        openPanel.canChooseDirectories = false
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.runModal()
        let items = openPanel.urls.map { (url) -> Rule in
            let bundle = Bundle(url: url)!
            let id = bundle.bundleIdentifier!
            
            AppManager.default.propagate(behavior: .media, forApp: id, at: url, from: .rule)
            return Rule(id: id, url: url, behavior: .media)
        }
        rulesSet.formUnion(items)
    }
    
    /// Remove a rule for a given application.
    private func removeRule() {
        guard let items = itemsArrayController.selectedObjects as? [Rule] else { return }
        items.forEach { (item) in
            AppManager.default.propagate(behavior: .inferred, forApp: item.id, at: item.url, from: .rule)
        }
        itemsArrayController.remove(self)
    }
    
    // MARK: - Actions
    
    @IBAction func operateRuleCollection(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            self.addRule()
        default:
            self.removeRule()
        }
    }
    
    
}
