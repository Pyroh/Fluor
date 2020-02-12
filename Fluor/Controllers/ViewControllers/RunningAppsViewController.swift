//
//  RunningAppsViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 21/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class RunningAppsViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var itemsArrayController: NSArrayController!
    
    @objc dynamic var runningAppsArray = [RunningApp]()
    @objc dynamic var showAll: Bool = BehaviorManager.default.showAllRunningProcesses {
        didSet { self.reloadData() }
    }
    @objc dynamic var searchPredicate: NSPredicate?
    @objc dynamic var sortDescriptors: [NSSortDescriptor] = [.init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
    
    private var tableContentAnimator: TableViewContentAnimator<RunningApp>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableContentAnimator = TableViewContentAnimator(tableView: tableView, arrayController: itemsArrayController)
        self.tableContentAnimator.performUnanimated {
            self.reloadData()
        }
        
        self.applyAsObserver()
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    /// Called whenever an application is launched by the system or the user.
    ///
    /// - parameter notification: The notification.
    @objc private func appDidLaunch(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let id = app.bundleIdentifier ?? app.executableURL?.lastPathComponent,
            let url = app.bundleURL ?? app.executableURL else { return }
        let isApp = app.activationPolicy == .regular
        guard self.showAll || isApp else { return }
        let behavior = BehaviorManager.default.behaviorForApp(id: id)
        let item = RunningApp(id: id, url: url, behavior: behavior, pid: app.processIdentifier, isApp: isApp)
        
        self.runningAppsArray.append(item)
    }
    
    /// Called whenever an application is terminated by the system or the user.
    ///
    /// - parameter notification: The notification.
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let item = runningAppsArray.first(where: { $0.pid == app.processIdentifier }), let index = runningAppsArray.firstIndex(of: item) else { return }
        self.runningAppsArray.remove(at: index)
    }
    
    /// Set `self` as an observer for *launch* and *terminate* notfications.
    private func applyAsObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
    }
    
    /// Load all running applications and populate the table view with corresponding data.
    private func reloadData() {
        self.runningAppsArray = self.getRunningApps()
    }

    private func getRunningApps() -> [RunningApp] {
        return NSWorkspace.shared.runningApplications.compactMap { (app) -> RunningApp? in
            guard let id = app.bundleIdentifier ?? app.executableURL?.lastPathComponent, let url = app.bundleURL ?? app.executableURL else { return nil }
            let isApp = app.activationPolicy == .regular
            guard showAll || isApp else { return nil }
            
            let behavior = BehaviorManager.default.behaviorForApp(id: id)
            let pid = app.processIdentifier
            
            return RunningApp(id: id, url: url, behavior: behavior, pid: pid, isApp: isApp)
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool { false }
}
