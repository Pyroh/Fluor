//
//  RunningAppsViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 21/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class RunningAppsViewController: NSViewController, BehaviorDidChangeHandler, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var itemsArrayController: NSArrayController!
    
    @objc dynamic var runningAppsArray = [RuleItem]()
    @objc dynamic var showAll: Bool = BehaviorManager.default.showAllRunningProcesses() {
        didSet { self.reloadData() }
    }
    @objc dynamic var searchPredicate: NSPredicate?
    @objc dynamic var sortDescriptors: [NSSortDescriptor] = [.init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
    
    private var tableContentAnimator: TableViewContentAnimator<RuleItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableContentAnimator = TableViewContentAnimator(tableView: tableView, arrayController: itemsArrayController)
        tableContentAnimator.performUnanimated {
            self.reloadData()
        }
        
        self.applyAsObserver()
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        self.stopObservingBehaviorDidChange()
    }
    
    func behaviorDidChangeForApp(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any], userInfo["source"] as? NotificationSource != .runningAppWindow else { return }
        guard let appId = userInfo["id"] as? String, let appBehavior = userInfo["behavior"] as? AppBehavior else { return }
        guard let index = runningAppsArray.index(where: { $0.id == appId }) else { return }
        runningAppsArray[index].behavior = appBehavior
    }
    
    /// Called whenever an application is launched by the system or the user.
    ///
    /// - parameter notification: The notification.
    @objc private func appDidLaunch(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let appId = app.bundleIdentifier,
            let appURL = app.bundleURL,
            let appIcon = app.icon else { return }
        let appPath = appURL.path
        let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
        let behavior = BehaviorManager.default.behaviorForApp(id: appId)
        let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: behavior, kind: .runningApp, pid: app.processIdentifier)
        
        runningAppsArray.append(item)
    }
    
    /// Called whenever an application is terminated by the system or the user.
    ///
    /// - parameter notification: The notification.
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let item = runningAppsArray.first(where: { $0.pid == app.processIdentifier }), let index = runningAppsArray.index(of: item) else { return }
        runningAppsArray.remove(at: index)
    }
    
    /// Set `self` as an observer for *launch* and *terminate* notfications.
    private func applyAsObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        startObservingBehaviorDidChange()
    }
    
    /// Load all running applications and populate the table view with corresponding data.
    private func reloadData() {
        self.runningAppsArray = self.fetchRunningApps()
    }

    private func fetchRunningApps() -> [RuleItem] {
        return NSWorkspace.shared.runningApplications.flatMap { (app) -> RuleItem? in
            guard let appId = app.bundleIdentifier, let appURL = app.bundleURL, let appIcon = app.icon else { return nil }
            let isApp = app.activationPolicy == .regular
            guard showAll || isApp else { return nil }
            let appPath = appURL.path
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            let behavior = BehaviorManager.default.behaviorForApp(id: appId)
            let pid = app.processIdentifier
            return RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: behavior, kind: .runningApp, isApp: isApp, pid: pid)
        }
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
