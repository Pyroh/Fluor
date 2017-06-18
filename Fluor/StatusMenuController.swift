//
//  StatusMenuController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var menuController: MenuItemsController!
    @IBOutlet weak var behaviorController: BehaviorController!
    
    private var rulesController: RulesEditorWindowController?
    private var aboutController: AboutWindowController?
    private var preferencesController: NSWindowController?
    private var runningAppsController: RunningAppsWindowController?
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    override func awakeFromNib() {
        setupStatusMenu()
        menuController.setup()
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NSWindowWillClose, object: object)
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
        case "DefaultSwitchMethod"?:
            switch BehaviorManager.default.switchMethod {
            case .windowSwitch:
                print("window")
            case .fnKey:
                print("key")
            }
        default:
            return
        }
    }
    
    // MARK: Private functions
    
    /// Setup the status bar's item
    private func setupStatusMenu() {
        statusItem.menu = statusMenu
        if BehaviorManager.default.useLightIcon() {
            statusItem.image = BehaviorManager.default.isDisabled() ? #imageLiteral(resourceName: "lighIconDisabledTemplate") : #imageLiteral(resourceName: "appleModeTemplate")
        } else {
            statusItem.image = BehaviorManager.default.isDisabled() ? #imageLiteral(resourceName: "iconDisabledTemplate") : #imageLiteral(resourceName: "iconAppleModeTemplate")
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
    
    // MARK: IBActions
    
    /// Show the *Edit Rules* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func editRules(_ sender: AnyObject) {
        guard rulesController == nil else {
            rulesController?.window?.orderFrontRegardless()
            return
        }
        rulesController = RulesEditorWindowController(windowNibName: "RulesEditorWindowController")
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: Notification.Name.NSWindowWillClose, object: rulesController?.window)
        rulesController?.window?.orderFrontRegardless()
    }
    
    /// Show the *About* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showAbout(_ sender: AnyObject) {
        guard aboutController == nil else {
            aboutController?.window?.orderFrontRegardless()
            return
        }
        aboutController = AboutWindowController(windowNibName: "AboutWindowController")
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: Notification.Name.NSWindowWillClose, object: aboutController?.window)
        aboutController?.window?.orderFrontRegardless()
    }
    
    /// Show the *Preferences* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showPreferences(_ sender: AnyObject) {
        guard preferencesController == nil else {
            preferencesController?.window?.orderFrontRegardless()
            return
        }
        preferencesController = NSWindowController(windowNibName: "PreferencesWindowController")
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: Notification.Name.NSWindowWillClose, object: preferencesController?.window)
        preferencesController?.window?.orderFrontRegardless()
    }
    
    /// Show the *Running Applications* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showRunningApps(_ sender: AnyObject) {
        guard runningAppsController == nil else {
            runningAppsController?.window?.orderFrontRegardless()
            return
        }
        runningAppsController = RunningAppsWindowController(windowNibName: "RunningAppsWindowController")
        NotificationCenter.default.addObserver(self, selector: #selector(someWindowWillClose(notification:)), name: Notification.Name.NSWindowWillClose, object: runningAppsController?.window)
        runningAppsController?.window?.orderFrontRegardless()
    }
    
    
    /// Enable or disable Fluor fn keys management. 
    /// If disabled the keyboard behaviour is set as its behaviour before app launch.
    ///
    /// - Parameter sender: The object that sent the action.
    @IBAction func toggleApplicationState(_ sender: NSMenuItem) {
        let enabled = sender.state == 1
        if enabled {
            statusItem.image = BehaviorManager.default.useLightIcon() ? #imageLiteral(resourceName: "appleModeTemplate") : #imageLiteral(resourceName: "iconAppleModeTemplate")
        } else {
            statusItem.image = BehaviorManager.default.useLightIcon() ? #imageLiteral(resourceName: "lighIconDisabledTemplate") : #imageLiteral(resourceName: "iconDisabledTemplate")
        }
        behaviorController.setApplication(state: enabled)
    }
    
    /// Terminate the application.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func quitApplication(_ sender: AnyObject) {
        resignAsObserver()
        NSWorkspace.shared().notificationCenter.removeObserver(self)
        behaviorController.performTerminationCleaning()
        NSApp.terminate(self)
    }
}
