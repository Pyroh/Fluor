//
//  StatusMenuController.swift
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
import DefaultsWrapper

class StatusMenuController: NSObject, NSMenuDelegate, NSWindowDelegate, MenuControlObserver {
    //MARK: - Menu Delegate
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet var menuItemsController: MenuItemsController!
    @IBOutlet var behaviorController: BehaviorController!
    
    private var rulesController: RulesEditorWindowController?
    private var aboutController: AboutWindowController?
    private var preferencesController: PreferencesWindowController?
    private var runningAppsController: RunningAppWindowController?
    
    var statusItem: NSStatusItem!

    override func awakeFromNib() {
        setupStatusMenu()
        self.menuItemsController.setupController()
        self.behaviorController.setupController()
        startObservingUsesLightIcon()
        startObservingMenuControlNotification()
    }
    
    deinit {
        stopObservingUsesLightIcon()
        stopObservingSwitchMenuControlNotification()
    }
    
    func windowWillClose(_ notification: Notification) {
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
        case UserDefaultsKeyName.useLightIcon.rawValue?:
            adaptStatusMenuIcon()
        default:
            return
        }
    }
    
    // MARK: - Private functions
    
    /// Setup the status bar's item
    private func setupStatusMenu() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        self.statusItem.menu = statusMenu
        adaptStatusMenuIcon()
    }
    
    
    /// Adapt status bar icon from user's settings.
    private func adaptStatusMenuIcon() {
        let disabledApp = AppManager.default.isDisabled
        let usesLightIcon = AppManager.default.useLightIcon
        switch (disabledApp, usesLightIcon) {
        case (false, false): statusItem.image = #imageLiteral(resourceName: "IconAppleMode")
        case (false, true): statusItem.image = #imageLiteral(resourceName: "AppleMode")
        case (true, false): statusItem.image = #imageLiteral(resourceName: "IconDisabled")
        case (true, true): statusItem.image = #imageLiteral(resourceName: "LighIconDisabled")
        }
    }
    
    /// Register self as an observer for some notifications.
    private func startObservingUsesLightIcon() {
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaultsKeyName.useLightIcon.rawValue, options: [], context: nil)
    }
    
    /// Unregister self as an observer for some notifications.
    private func stopObservingUsesLightIcon() {
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaultsKeyName.useLightIcon.rawValue, context: nil)
    }
    
    // MARK: - NSWindowDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        self.behaviorController.adaptToAccessibilityTrust()
    }
    
    // MARK: - MenuControlObserver
    
    func menuNeedsToOpen(notification: Notification) { }
    
    func menuNeedsToClose(notification: Notification) {
        if let userInfo = notification.userInfo, let animated = userInfo["animated"] as? Bool, !animated {
            self.statusMenu.cancelTrackingWithoutAnimation()
        } else {
            self.statusMenu.cancelTracking()
        }
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
        rulesController = RulesEditorWindowController.instantiate()
        rulesController?.window?.delegate = self
        rulesController?.window?.orderFrontRegardless()
    }
    
    /// Show the *About* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showAbout(_ sender: AnyObject) {
        guard aboutController == nil else {
            aboutController?.window?.makeKeyAndOrderFront(self)
            aboutController?.window?.makeMain()
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        aboutController = AboutWindowController.instantiate()
        aboutController?.window?.delegate = self
        aboutController?.window?.makeKeyAndOrderFront(self)
        aboutController?.window?.makeMain()
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
        self.preferencesController = PreferencesWindowController.instantiate()
        preferencesController?.window?.delegate = self
        preferencesController?.window?.makeKeyAndOrderFront(self)
        preferencesController?.window?.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Show the *Running Applications* window.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func showRunningApps(_ sender: AnyObject) {
        guard runningAppsController == nil else {
            runningAppsController?.window?.orderFrontRegardless()
            return
        }
        runningAppsController = RunningAppWindowController.instantiate()
        runningAppsController?.window?.delegate = self
        runningAppsController?.window?.orderFrontRegardless()
    }
    
    
    /// Enable or disable Fluor fn keys management. 
    /// If disabled the keyboard behaviour is set as its behaviour before app launch.
    ///
    /// - Parameter sender: The object that sent the action.
    @IBAction func toggleApplicationState(_ sender: NSMenuItem) {
        let disabled = sender.state == .off
        if disabled {
            self.statusItem.image = AppManager.default.useLightIcon ? #imageLiteral(resourceName: "LighIconDisabled") : #imageLiteral(resourceName: "IconDisabled")
        } else {
            self.statusItem.image = AppManager.default.useLightIcon ? #imageLiteral(resourceName: "AppleMode") : #imageLiteral(resourceName: "IconAppleMode")
        }
        self.behaviorController.setApplicationIsEnabled(disabled)
    }
    
    /// Terminate the application.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func quitApplication(_ sender: AnyObject) {
        self.stopObservingUsesLightIcon()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        self.behaviorController.performTerminationCleaning()
        NSApp.terminate(self)
    }
}
