//
//  BehaviorController.swift
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
import os.log
import UserNotifications

class BehaviorController: NSObject, BehaviorDidChangeObserver, DefaultModeViewControllerDelegate, SwitchMethodDidChangeObserver, ActiveApplicationDidChangeObserver {
    @IBOutlet weak var statusMenuController: StatusMenuController!
    @IBOutlet var defaultModeViewController: DefaultModeViewController!
    
    @objc dynamic private var isKeySwitchCapable: Bool = false
    private var globalEventManager: Any?
    private var fnDownTimestamp: TimeInterval? = nil
    private var shouldHandleFNKey: Bool = false
    
    private var currentMode: FKeyMode = .media
    private var onLaunchKeyboardMode: FKeyMode = .media
    private var currentAppID: String = ""
    private var currentAppURL: URL?
    private var currentAppName: String?
    private var currentBehavior: AppBehavior = .inferred
    private var switchMethod: SwitchMethod = .window
    
    func setupController() {
        self.onLaunchKeyboardMode = AppManager.default.getCurrentFKeyMode()
        self.currentMode = self.onLaunchKeyboardMode
        self.switchMethod = AppManager.default.switchMethod
        
        self.applyAsObserver()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appMustSleep(notification:)), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appMustSleep(notification:)), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appMustWake(notification:)), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appMustWake(notification:)), name: NSWorkspace.didWakeNotification, object: nil)
        
        guard !AppManager.default.isDisabled else { return }
        if let currentApp = NSWorkspace.shared.frontmostApplication, let id = currentApp.bundleIdentifier ?? currentApp.executableURL?.lastPathComponent {
            self.adaptModeForApp(withId: id)
//            self.updateAppBehaviorViewFor(app: currentApp, id: id)
        }
    }
    
    func setApplicationIsEnabled(_ enabled: Bool) {
        if enabled {
            self.adaptModeForApp(withId: self.currentAppID)
        } else {
            do { try FKeyManager.setCurrentFKeyMode(self.onLaunchKeyboardMode) }
            catch { AppErrorManager.terminateApp(withReason: error.localizedDescription) }
        }
    }
    
    func performTerminationCleaning() {
        if AppManager.default.shouldRestoreStateOnQuit {
            let state: FKeyMode
            if AppManager.default.shouldRestorePreviousState {
                state = self.onLaunchKeyboardMode
            } else {
                state = AppManager.default.onQuitState
            }
            
            do { try FKeyManager.setCurrentFKeyMode(state) }
            catch { fatalError() }
        }
    }
    
    func adaptToAccessibilityTrust() {
        if AXIsProcessTrusted() {
            self.isKeySwitchCapable = true
            self.ensureMonitoringFlagKey()
        } else {
            self.isKeySwitchCapable = false
            self.stopMonitoringFlagKey()
        }
    }
    
    // MARK: - ActiveApplicationDidChangeObserver
    
    func activeApplicationDidChangw(notification: Notification) {
        self.adaptToAccessibilityTrust()
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let id = app.bundleIdentifier ?? app.executableURL?.lastPathComponent else { return }
        self.currentAppName = app.localizedName
        self.currentAppID = id
        self.currentAppURL = app.bundleURL
        if !AppManager.default.isDisabled {
            self.adaptModeForApp(withId: id)
        }
    }
    
    // MARK: - BehaviorDidChangeObserver
    
    /// React to the change of the function keys behavior for one app.
    ///
    /// - parameter notification: The notification.
    func behaviorDidChangeForApp(notification: Notification) {
        guard let id = notification.userInfo?["id"] as? String else { return }
        
        if id == self.currentAppID {
            self.adaptModeForApp(withId: id)
        }
    }
    
    // MARK: - SwitchMethodDidChangeObserver
    
    func switchMethodDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo, let method = userInfo["method"] as? SwitchMethod else { return }
        self.switchMethod = method
        switch method {
        case .window, .hybrid:
            self.startObservingBehaviorDidChange()
            self.adaptModeForApp(withId: self.currentAppID)
        case .key:
            self.stopObservingBehaviorDidChange()
            self.currentMode = AppManager.default.defaultFKeyMode
            self.changeKeyboard(mode: currentMode)
        }
    }
    
    // MARK: - DefaultModeViewControllerDelegate
    
    func defaultModeController(_ controller: DefaultModeViewController, didChangeModeTo mode: FKeyMode) {
        switch self.switchMethod {
        case .window, .hybrid:
            self.adaptModeForApp(withId: self.currentAppID)
        case .key:
            self.changeKeyboard(mode: mode)
            self.currentMode = mode
        }
    }
    
    // MARK: - Private functions
    
    /// Disable this session's Fluor instance in order to prevent it from messing when potential other sessions' ones.
    ///
    /// - Parameter notification: The notification.
    @objc private func appMustSleep(notification: Notification) {
        do { try FKeyManager.setCurrentFKeyMode(self.onLaunchKeyboardMode) }
        catch { os_log("Unable to reset FKey mode to pre-launch mode", type: .error) }
        self.resignAsObserver()
    }
    
    
    /// Reenable this session's Fluor instance.
    ///
    /// - Parameter notification: The notification.
    @objc private func appMustWake(notification: Notification) {
        self.changeKeyboard(mode: currentMode)
        self.applyAsObserver()
    }
    
    /// Register self as an observer for some notifications.
    private func applyAsObserver() {
        if self.switchMethod != .key { self.startObservingBehaviorDidChange() }
        self.startObservingSwitchMethodDidChange()
        self.startObservingActiveApplicationDidChange()
        
        self.adaptToAccessibilityTrust()
    }
    
    /// Unregister self as an observer for some notifications.
    private func resignAsObserver() {
        if self.switchMethod != .key { self.stopObservingBehaviorDidChange() }
        self.stopObservingSwitchMethodDidChange()
        self.stopObservingActiveApplicationDidChange()
        
        self.stopMonitoringFlagKey()
    }
    
    /// Set the function keys' behavior for the given app.
    ///
    /// - parameter id: The app's bundle id.
    private func adaptModeForApp(withId id: String) {
        guard self.switchMethod != .key else { return }
        let behavior = AppManager.default.behaviorForApp(id: id)
        let mode = AppManager.default.keyboardStateFor(behavior: behavior)
        guard mode != self.currentMode else { return }
        self.currentMode = mode
        self.changeKeyboard(mode: mode)
}
    
    private func changeKeyboard(mode: FKeyMode) {
        do { try FKeyManager.setCurrentFKeyMode(mode) }
        catch { AppErrorManager.terminateApp(withReason: error.localizedDescription) }
        
        switch mode {
        case .media:
            os_log("Switch to Apple Mode for %@", self.currentAppID)
            self.statusMenuController.statusItem.image = AppManager.default.useLightIcon ? #imageLiteral(resourceName: "AppleMode") : #imageLiteral(resourceName: "IconAppleMode") 
        case .function:
            NSLog("Switch to Other Mode for %@", self.currentAppID)
            self.statusMenuController.statusItem.image = AppManager.default.useLightIcon ? #imageLiteral(resourceName: "OtherMode") : #imageLiteral(resourceName: "IconOtherMode")
        }
        
        UserNotificationHelper.sendModeChangedTo(mode)
    }
    
    private func manageKeyPress(event: NSEvent) {
        guard self.switchMethod != .window else { return }
        if event.type == .flagsChanged {
            if event.modifierFlags.contains(.function) {
                if event.keyCode == 63 {
                    self.fnDownTimestamp = event.timestamp
                    self.shouldHandleFNKey = true
                } else {
                    self.fnDownTimestamp = nil
                    self.shouldHandleFNKey = false
                }
            } else {
                if self.shouldHandleFNKey, let timestamp = self.fnDownTimestamp {
                    let delta = (event.timestamp - timestamp) * 1000
                    self.shouldHandleFNKey = false
                    if event.keyCode == 63, delta <= AppManager.default.fnKeyMaximumDelay {
                        switch self.switchMethod {
                        case .key:
                            self.fnKeyPressedImpactsGlobal()
                        case .hybrid:
                            self.fnKeyPressedImpactsApp()
                        default:
                            return
                        }
                    }
                }
            }
        } else if self.shouldHandleFNKey {
            self.shouldHandleFNKey = false
            self.fnDownTimestamp = nil
        }
    }
    
    private func fnKeyPressedImpactsGlobal() {
        let mode = self.currentMode.counterPart
        AppManager.default.defaultFKeyMode = mode
        UserNotificationHelper.holdNextModeChangedNotification = true
        self.changeKeyboard(mode: mode)
        self.currentMode = mode
        UserNotificationHelper.sendGlobalModeChangedTo(mode)
    }
    
    private func fnKeyPressedImpactsApp() {
        guard let url = self.currentAppURL else { AppErrorManager.terminateApp(withReason: "An unexpected error occured") }
        let appBehavior = AppManager.default.behaviorForApp(id: self.currentAppID)
        let defaultBehavior = AppManager.default.defaultFKeyMode.behavior
        
        let newAppBehavior: AppBehavior
        
        switch appBehavior {
        case .inferred:
            newAppBehavior = defaultBehavior.counterPart
        case defaultBehavior.counterPart:
            newAppBehavior = defaultBehavior
        case defaultBehavior:
            newAppBehavior = .inferred
        default:
            newAppBehavior = .inferred
        }
        
        UserNotificationHelper.holdNextModeChangedNotification = self.currentAppName != nil
        AppManager.default.propagate(behavior: newAppBehavior, forApp: self.currentAppID , at: url, from: .fnKey)
        if let name = self.currentAppName {
            UserNotificationHelper.sendFKeyChangedAppBehaviorTo(newAppBehavior, appName: name)
        }
    }
    
    private func ensureMonitoringFlagKey() {
        guard self.isKeySwitchCapable && self.globalEventManager == nil else { return }
        self.globalEventManager = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown], handler: manageKeyPress)
    }
    
    private func stopMonitoringFlagKey() {
        guard let gem = self.globalEventManager else { return }
        NSEvent.removeMonitor(gem)
        if self.globalEventManager != nil {
            self.globalEventManager = nil
        }
    }
}
