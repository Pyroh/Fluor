//
//  RunningAppsWindowController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class RunningAppsWindowController: NSWindowController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var runningAppsArrayController: NSArrayController!
    
    dynamic var runningAppsArray = [RunningAppItem]()
    dynamic var runningAppsCount: Int = 0
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.formUnion(.nonactivatingPanel)
        window?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        runningAppsArrayController.sortDescriptors = [sortDescriptor]
        loadData()
        applyAsObserver()
    }
    
    deinit {
        NSWorkspace.shared().notificationCenter.removeObserver(self)
    }
    
    /// Update the behavior of a given application. It changes the segmented control's selected item of the right table view's row.
    ///
    /// - parameter id:       The application bundle id.
    /// - parameter behavior: The new behavior.
    func updateBehaviorForApp(id: String, behavior: AppBehavior) {
        guard let index = runningAppsArray.index(where: { $0.id == id }) else { return }
        // We don't want to fire the `didSet` of the `behavior` cvar.
        runningAppsArray[index] = RunningAppItem(fromItem: runningAppsArray[index], withBehavior: behavior.rawValue)
    }
    
    /// Called whenever an application is launched by the system or the user.
    ///
    /// - parameter notification: The notification.
    @objc private func appDidLaunch(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication,
            let appId = app.bundleIdentifier,
            let appURL = app.bundleURL,
            let appIcon = app.icon else { return }
        let appPath = appURL.path
        let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
        let behavior = BehaviorManager.default.behaviorForApp(id: appId).rawValue
        let item = RunningAppItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: behavior)
        
        runningAppsArray.append(item)
    }
    
    /// Called whenever an application is terminated by the system or the user.
    ///
    /// - parameter notification: The notification.
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication,
            let appId = app.bundleIdentifier,
            let index = runningAppsArray.index(where: { $0.id == appId }) else { return }
        runningAppsArray.remove(at: index)
    }
    
    /// Set `self` as an observer for *launch* and *terminate* notfications.
    private func applyAsObserver() {
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSNotification.Name.NSWorkspaceDidLaunchApplication, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSNotification.Name.NSWorkspaceDidTerminateApplication, object: nil)
    }
    
    /// Load all running applications and populate the table view with corresponding datas.
    private func loadData() {
        runningAppsArray = NSWorkspace.shared().runningApplications.flatMap { (app) -> RunningAppItem? in
            guard let appId = app.bundleIdentifier, let appURL = app.bundleURL, let appIcon = app.icon else { return nil }
            guard app.activationPolicy == .regular else { return nil }
            let appPath = appURL.path
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            let behavior = BehaviorManager.default.behaviorForApp(id: appId).rawValue
            return RunningAppItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: behavior)
        }
    }
}
