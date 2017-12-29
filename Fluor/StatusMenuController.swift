//
//  StatusMenuController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSMenuDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var menuItemsController: MenuItemsController!
    @IBOutlet weak var behaviorController: BehaviorController!
    
    private var rulesController: RulesEditorWindowController?
    private var aboutController: AboutWindowController?
    private var preferencesController: NSWindowController?
    private var runningAppsController: RunningAppsWindowController?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    override func awakeFromNib() {
        setupStatusMenu()
        menuItemsController.setup()
        behaviorController.setup()
        applyAsObserver()
    }
    
    deinit {
        resignAsObserver()
    }
    
    /// When a window was closed this methods takes care of releasing its controller.
    ///
    /// - parameter notification: The notification.
    @objc private func someWindowWillClose(notification: Notification) {
        guard let object = notification.object as? NSWindow else { return }
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: object)
        if object.isEqual(rulesController?.window) {
            rulesController = nil
        } else if object.isEqual(aboutController?.window) {
            aboutController = nil
        } else if object.isEqual(preferencesController?.window) {
            preferencesController = nil
        } else if object.isEqual(runningAppsController?.window) {
            runningAppsController = nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case BehaviorManager.DefaultsKeys.useLightIcon?:
            adaptStatusMenuIcon()
        default:
            return
        }
    }
    
    // MARK: Private functions
    
    /// Setup the status bar's item
    private func setupStatusMenu() {
        statusItem.menu = statusMenu
        adaptStatusMenuIcon()
    }
    
    
    /// Adapt status bar icon from user's settings.
    private func adaptStatusMenuIcon() {
        if BehaviorManager.default.useLightIcon() {
            statusItem.image = BehaviorManager.default.isDisabled() ? #imageLiteral(resourceName: "LighIconDisabled") : #imageLiteral(resourceName: "AppleMode")
        } else {
            statusItem.image = BehaviorManager.default.isDisabled() ? #imageLiteral(resourceName: "IconDisabled") : #imageLiteral(resourceName: "IconAppleMode")
        }
    }
    
    /// Register self as an observer for some notifications.
    private func applyAsObserver() {
        UserDefaults.standard.addObserver(self, forKeyPath: BehaviorManager.DefaultsKeys.useLightIcon, options: [], context: nil)
    }
    
    /// Unregister self as an observer for some notifications.
    private func resignAsObserver() {
        UserDefaults.standard.removeObserver(self, forKeyPath: BehaviorManager.DefaultsKeys.useLightIcon, context: nil)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        behaviorController.adaptToAccessibilityTrust()
    }
    
    // MARK: IBActions
    
    /// Show the *Edit Rules* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func editRules(_ sender: AnyObject) {
        guard rulesController == nil else {
            rulesController?.window?.orderFrontRegardless()
            return
        }
        rulesController = RulesEditorWindowController(windowNibName: NSNib.Name(rawValue: "RulesEditorWindowController"))
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: NSWindow.willCloseNotification, object: rulesController?.window)
        rulesController?.window?.orderFrontRegardless()
    }
    
    /// Show the *About* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showAbout(_ sender: AnyObject) {
        guard aboutController == nil else {
            preferencesController?.window?.makeKeyAndOrderFront(self)
            preferencesController?.window?.makeMain()
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        aboutController = AboutWindowController(windowNibName: NSNib.Name(rawValue: "AboutWindowController"))
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: NSWindow.willCloseNotification, object: aboutController?.window)
        preferencesController?.window?.makeKeyAndOrderFront(self)
        preferencesController?.window?.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Show the *Preferences* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showPreferences(_ sender: AnyObject) {
        guard preferencesController == nil else {
            preferencesController?.window?.makeKeyAndOrderFront(self)
            preferencesController?.window?.makeMain()
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        if let ctrl = NSStoryboard(name: .preferences, bundle: nil).instantiateInitialController() as? NSWindowController {
            preferencesController = ctrl
            NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: NSWindow.willCloseNotification, object: preferencesController?.window)
            preferencesController?.window?.makeKeyAndOrderFront(self)
            preferencesController?.window?.makeMain()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    /// Show the *Running Applications* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showRunningApps(_ sender: AnyObject) {
        guard runningAppsController == nil else {
            runningAppsController?.window?.orderFrontRegardless()
            return
        }
        runningAppsController = RunningAppsWindowController(windowNibName: NSNib.Name(rawValue: "RunningAppsWindowController"))
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: NSWindow.willCloseNotification, object: runningAppsController?.window)
        runningAppsController?.window?.orderFrontRegardless()
    }
    
    
    /// Enable or disable Fluor fn keys management. 
    /// If disabled the keyboard behaviour is set as its behaviour before app launch.
    ///
    /// - Parameter sender: The object that sent the action.
    @IBAction func toggleApplicationState(_ sender: NSMenuItem) {
        let enabled = sender.state == .on
        if enabled {
            statusItem.image = BehaviorManager.default.useLightIcon() ? #imageLiteral(resourceName: "AppleMode") : #imageLiteral(resourceName: "IconAppleMode")
        } else {
            statusItem.image = BehaviorManager.default.useLightIcon() ? #imageLiteral(resourceName: "LighIconDisabled") : #imageLiteral(resourceName: "IconDisabled")
        }
        behaviorController.setApplication(state: enabled)
    }
    
    /// Terminate the application.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func quitApplication(_ sender: AnyObject) {
        resignAsObserver()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        behaviorController.performTerminationCleaning()
        NSApp.terminate(self)
    }
}
