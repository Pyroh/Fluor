//
//  RunningAppsViewController.swift
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

class RunningAppsViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var itemsArrayController: NSArrayController!
    
    @objc dynamic var runningAppsArray = [RunningApp]()
    @objc dynamic var showAll: Bool = AppManager.default.showAllRunningProcesses {
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
        let behavior = AppManager.default.behaviorForApp(id: id)
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
            
            let behavior = AppManager.default.behaviorForApp(id: id)
            let pid = app.processIdentifier
            
            return RunningApp(id: id, url: url, behavior: behavior, pid: pid, isApp: isApp)
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool { false }
}
