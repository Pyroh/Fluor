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
    public static let BehaviorDidChangeForApp = NSNotification.Name("kBehaviorDidChangeForApp")
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var stateView: StateView!
    @IBOutlet weak var currentAppView: CurrentAppView!
    
    private var currentKeyboardState: KeyboardState = .error
    private var currentID: String = ""
    private var currentBehavior: AppBehavior = .infered
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    deinit {
        resignAsObserver()
    }
    
    override func awakeFromNib() {
        currentKeyboardState = BehaviorManager.default.getActualStateAccordingToPreferences()
        setupStatusItem()
        applyAsObserver()
    }
    
    // MARK: Operations callbacks
    
    @objc private func activeAppDidChange(notification: NSNotification) {
        guard let app = notification.userInfo?[NSWorkspaceApplicationKey] as? NSRunningApplication,
            let id = app.bundleIdentifier else { return }
        currentID = id
        updateAppBehaviorViewFor(app: app, id: id)
        adaptBehaviorForApp(id: id)
    }
    
    @objc private func stateViewDidChangeState(notification: NSNotification) {
        guard let passedState = notification.userInfo?["state"] as? Bool else { return }
        print(passedState)
    }
    
    @objc private func appDidChangeBehavior(notification: NSNotification) {
        guard let behavior = notification.userInfo?["behavior"] as? AppBehavior else { return }
        setBehaviorForApp(id: currentID, behavior: behavior)
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
        NotificationCenter.default.addObserver(self, selector: #selector(stateViewDidChangeState(notification:)), name: Notification.Name.StateViewDidChangeState, object: stateView)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidChangeBehavior(notification:)), name: Notification.Name.BehaviorDidChangeForApp, object: currentAppView)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activeAppDidChange(notification:)), name: NSNotification.Name.NSWorkspaceDidActivateApplication, object: nil)
    }
    
    private func resignAsObserver() {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared().notificationCenter.removeObserver(self)
    }
    
    private func updateAppBehaviorViewFor(app: NSRunningApplication, id: String) {
        currentAppView.enabled(id != Bundle.main.bundleIdentifier!)
        currentAppView.setCurrent(app: app, behavior: BehaviorManager.default.behaviorForApp(id: id))
    }
    
    private func setBehaviorForApp(id: String, behavior: AppBehavior) {
        BehaviorManager.default.setBehaviorForApp(id: id, behavior: behavior)
        adaptBehaviorForApp(id: id)
    }
    
    private func adaptBehaviorForApp(id: String) {
        let behavior = BehaviorManager.default.behaviorForApp(id: id)
        let state = BehaviorManager.keyboardStateFor(behavior: behavior, currentState: currentKeyboardState)
        guard state != currentKeyboardState else { return }
        currentKeyboardState = state
        switch state {
        case .apple:
            setFnKeysToAppleMode()
        case .other:
            setFnKeysToOtherMode()
        default:
            // Soneone should handle this, no ?
            return
        }
    }
    
    // MARK: IBActions
    @IBAction func editRules(_ sender: AnyObject) {
        NSLog("Should edit rules...")
    }
    
    @IBAction func quitApplication(_ sender: AnyObject) {
        setFnKeysToAppleMode()
        NSApp.terminate(self)
    }
}
