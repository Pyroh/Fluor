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
    
    private var rulesController: RulesEditorWindowController?
    
    private var currentState: KeyboardState = .error
    private var onLaunchKeyboardState: KeyboardState = .error
    private var currentID: String = ""
    private var currentBehavior: AppBehavior = .infered
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    deinit {
        resignAsObserver()
    }
    
    override func awakeFromNib() {
        onLaunchKeyboardState = BehaviorManager.default.getActualStateAccordingToPreferences()
        currentState = onLaunchKeyboardState
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
        guard let passedState = notification.userInfo?["state"] as? KeyboardState else { return }
        BehaviorManager.default.defaultKeyboardState = passedState
        adaptBehaviorForApp(id: currentID)
    }
    
    @objc private func behaviorDidChangeForApp(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let info = StatusMenuController.behaviorDidChangeUserInfoFor(dict: userInfo) else { return }
        setBehaviorForApp(id: info.id, behavior: info.behavior, url: info.url)
        switch notification.object! {
        case is CurrentAppView:
            rulesController?.loadData()
            adaptBehaviorForApp(id: info.id)
        default:
            if info.id == currentID {
                adaptBehaviorForApp(id: info.id)
                currentAppView.updateBehaviorForCurrentApp(info.behavior)
            }
        }
    }
    
    @objc private func rulesEditorWindowWillClose(notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NSWindowWillClose, object: rulesController?.window)
        rulesController = nil
    }
    
    // MARK: Private functions
    
    /// Setup the status bar's item
    private func setupStatusItem() {
        statusItem.menu = statusMenu
        statusItem.image = #imageLiteral(resourceName: "iconAppleModeTemplate")
        let statePlaceHolder = statusMenu.item(withTitle: "State")
        let currentPlaceHolder = statusMenu.item(withTitle: "Current")
        statePlaceHolder?.view = stateView
        currentPlaceHolder?.view = currentAppView
        stateView.setState(flag: BehaviorManager.default.defaultKeyboardState)
    }
    
    private func applyAsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(stateViewDidChangeState(notification:)), name: Notification.Name.StateViewDidChangeState, object: stateView)
        NotificationCenter.default.addObserver(self, selector: #selector(behaviorDidChangeForApp(notification:)), name: Notification.Name.BehaviorDidChangeForApp, object: nil)
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
    
    private func setBehaviorForApp(id: String, behavior: AppBehavior, url: URL) {
        BehaviorManager.default.setBehaviorForApp(id: id, behavior: behavior, url: url)
    }
    
    private func adaptBehaviorForApp(id: String) {
        let behavior = BehaviorManager.default.behaviorForApp(id: id)
        let state = BehaviorManager.default.keyboardStateFor(behavior: behavior)
        guard state != currentState else { return }
        currentState = state
        switch state {
        case .apple:
            NSLog("Switch to Apple Mode for %@", id)
            statusItem.image = #imageLiteral(resourceName: "iconAppleModeTemplate")
            setFnKeysToAppleMode()
        case .other:
            NSLog("Switch to Other Mode for %@", id)
            statusItem.image = #imageLiteral(resourceName: "iconOtherModeTemplate")
            setFnKeysToOtherMode()
        default:
            // Soneone should handle this, no ?
            return
        }
    }
    
    static func behaviorDidChangeUserInfoConstructor(id: String, url: URL, behavior: AppBehavior) -> [String: Any] {
        return ["id": id, "url": url, "behavior": behavior]
    }
    
    static func behaviorDidChangeUserInfoFor(dict: [AnyHashable: Any]) -> (id: String, url: URL, behavior: AppBehavior)? {
        guard let behavior = dict["behavior"] as? AppBehavior,
            let url = dict["url"] as? URL,
            let id = dict["id"] as? String else { return nil }
        return (id, url, behavior)
    }
    
    // MARK: IBActions
    @IBAction func editRules(_ sender: AnyObject) {
//        if rulesController == nil {
            rulesController = RulesEditorWindowController(windowNibName: "RulesEditorWindowController")
            rulesController?.window?.becomeMain()
            rulesController?.loadData()
//        } else {
//            rulesController?.showWindow(self)
//            rulesController?.window?.becomeMain()
//            rulesController?.loadData()
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(rulesEditorWindowWillClose(notification:)), name: Notification.Name.NSWindowWillClose, object: rulesController?.window)
        rulesController?.window?.orderFrontRegardless()
    }
    
    @IBAction func quitApplication(_ sender: AnyObject) {
        setFnKeysToAppleMode()
        NSApp.terminate(self)
    }
}
