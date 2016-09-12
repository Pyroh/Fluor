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
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.formUnion(.nonactivatingPanel)
        window?.setFrameAutosaveName("RunningAppsWindowAutosaveName")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        runningAppsArrayController.sortDescriptors = [sortDescriptor]
        loadData()
        applyAsObserver()
    }
    
    deinit {
        NSWorkspace.shared().notificationCenter.removeObserver(self)
    }
    
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
    
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication,
            let appId = app.bundleIdentifier,
            let index = runningAppsArray.index(where: { $0.id == appId }) else { return }
        runningAppsArray.remove(at: index)
    }
    
    private func applyAsObserver() {
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSNotification.Name.NSWorkspaceDidLaunchApplication, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSNotification.Name.NSWorkspaceDidTerminateApplication, object: nil)
    }
    
    private func loadData() {
        runningAppsArray = NSWorkspace.shared().runningApplications.flatMap { (app) -> RunningAppItem? in
            guard let appId = app.bundleIdentifier, let appUrl = app.bundleURL, let appIcon = app.icon else { return nil }
            let appName: String
            if let name = Bundle(path: appUrl.path)?.localizedInfoDictionary?["CFBundleName"] as? String {
                appName = name
            } else {
                appName = appUrl.deletingPathExtension().lastPathComponent
            }
            let behavior = BehaviorManager.default.behaviorForApp(id: appId).rawValue
            return RunningAppItem(id: appId, url: appUrl, icon: appIcon, name: appName, behavior: behavior)
        }
    }
    
    func updateBehaviorForApp(id: String, behavior: AppBehavior) {
        guard let index = runningAppsArray.index(where: { $0.id == id }) else { return }
        runningAppsArray[index].behavior = behavior.rawValue
    }
}
