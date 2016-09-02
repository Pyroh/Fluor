//
//  StatusMenuController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

extension NSNotification.Name {
    public static let StateViewDidChangeState = NSNotification.Name("kStateViewDidChangeState")
    public static let AppDidChangeBehavior = NSNotification.Name("kAppDidChangeBehavior")
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var stateView: StateView!
    @IBOutlet weak var currentAppView: CurrentAppView!
    
    private var currentID: String = ""
    private var currentBehavior: AppBehavior = .infered
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    deinit {
        resignAsObserver()
    }
    
    override func awakeFromNib() {
        setupStatusItem()
        applyAsObserver()
    }
    
    // MARK: Operations callbacks
    
    @objc private func activeAppDidChange(notification: NSNotification) {
        guard let app = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication,
            let id = app.bundleIdentifier else { return }
        currentID = id
        updateAppBehaviorViewFor(app: app, id: id)
    }
    
    @objc private func stateViewDidChangeState(notification: NSNotification) {
        guard let passedState = notification.userInfo?["state"] as? Bool else { return }
        print(passedState)
    }
    
    @objc private func appDidChangeBehavior(notification: NSNotification) {
        guard let behavior = notification.userInfo?["behavior"] as? AppBehavior else { return }
        print(behavior)
    }
    
    // MARK: Private functions
    
    /// Setup the status bar's item
    private func setupStatusItem() {
        statusItem.menu = statusMenu
        statusItem.image = NSImage(named: NSImageNameActionTemplate)
        let statePlaceHolder = statusMenu.item(withTitle: "State")
        let currentPlaceHolder = statusMenu.item(withTitle: "Current")
        statePlaceHolder?.view = stateView
        currentPlaceHolder?.view = currentAppView
    }
    
    
    private func applyAsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(stateViewDidChangeState(notification:)), name: NSNotification.Name.StateViewDidChangeState, object: stateView)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activeAppDidChange(notification:)), name: NSNotification.Name.NSWorkspaceDidActivateApplication, object: nil)
    }
    
    private func resignAsObserver() {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared().notificationCenter.removeObserver(self)
    }
    
    private func getActualStateAccordingToPreferences() -> Bool {
        switch getCurrentFnKeyState() {
        case AppleMode:
            return false
        case OtherMode:
            return true
        default:
            assertionFailure()
            return false
        }
    }
    
    private func updateAppBehaviorViewFor(app: NSRunningApplication, id: String) {
        currentAppView.enabled(id != Bundle.main.bundleIdentifier!)
        currentAppView.setCurrent(app: app, behavior: .apple)
    }
    
    private func setBehaviorForApp(id: String, behavior: AppBehavior) {
        
    }
    
    private func changeBehaviorForApp(id: String) {
        
    }
    
    // MARK: IBActions
    @IBAction func editRules(_ sender: AnyObject) {
        NSLog("Should edit rules...")
    }
    
    @IBAction func quitApplication(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}
