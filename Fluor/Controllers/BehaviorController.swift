//
//  BehaviorController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 24/05/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class BehaviorController: NSObject, BehaviorDidChangeHandler, DefaultModeViewControllerDelegate, SwitchMethodDidChangeHandler {
    @IBOutlet var currentAppViewController: CurrentAppViewController!
    @IBOutlet var statusMenuController: StatusMenuController!
    @IBOutlet var defaultModeViewController: DefaultModeViewController!
    @IBOutlet var switchMethodViewController: SwitchMethodViewController!
    
    @objc dynamic private var isKeySwitchCapable: Bool = false
    private var globalEventManager: Any?
    
    private var currentMode: KeyboardMode = .error
    private var onLaunchKeyboardMode: KeyboardMode = .error
    private var currentID: String = ""
    private var currentBehavior: AppBehavior = .inferred
    private var switchMethod: SwitchMethod = .window
    
    func setup() {
        onLaunchKeyboardMode = BehaviorManager.default.getActualStateAccordingToPreferences()
        currentMode = onLaunchKeyboardMode
        switchMethod = BehaviorManager.default.switchMethod
        
        self.applyAsObserver()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sessionDidBecomeInactive(notification:)), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sessionDidBecomeActive(notification:)), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
        
        guard !BehaviorManager.default.isDisabled() else { return }
        if let currentApp = NSWorkspace.shared.frontmostApplication, let id = currentApp.bundleIdentifier {
            adaptModeForApp(withId: id)
            updateAppBehaviorViewFor(app: currentApp, id: id)
        }
    }
    
    /// Register self as an observer for some notifications.
    private func applyAsObserver() {
        if switchMethod == .window { startObservingBehaviorDidChange() }
        startObservingSwitchMethodDidChange()
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeAppDidChange(notification:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        self.adaptToAccessibilityTrust()
    }
    
    /// Unregister self as an observer for some notifications.
    private func resignAsObserver() {
        if case .window = switchMethod {
            stopObservingBehaviorDidChange()
        }
        stopObservingSwitchMethodDidChange()
        
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.didActivateApplicationNotification, object: nil)
        if isKeySwitchCapable, let globalEventManager = globalEventManager {
            NSEvent.removeMonitor(globalEventManager)
        }
    }
    
    func setApplication(state enabled: Bool) {
        if enabled {
            adaptModeForApp(withId: currentID)
        } else {
            switch onLaunchKeyboardMode {
            case .apple:
                setFnKeysToAppleMode()
            default:
                setFnKeysToOtherMode()
            }
            currentMode = onLaunchKeyboardMode
        }
    }
    
    func performTerminationCleaning() {
        if BehaviorManager.default.shouldRestoreStateOnQuit() {
            let state: KeyboardMode
            if BehaviorManager.default.shouldRestorePreviousState() {
                state = onLaunchKeyboardMode
            } else {
                state = BehaviorManager.default.onQuitState()
            }
            switch state {
            case .apple:
                setFnKeysToAppleMode()
            default:
                setFnKeysToOtherMode()
            }
        }
    }
    
    /// React to active application change.
    ///
    /// - parameter notification: The notification.
    @objc private func activeAppDidChange(notification: Notification) {
        self.adaptToAccessibilityTrust()
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let id = app.bundleIdentifier else { return }
        currentID = id
        updateAppBehaviorViewFor(app: app, id: id)
        if !BehaviorManager.default.isDisabled() {
            adaptModeForApp(withId: id)
        }
    }
    
    /// React to the change of the function keys behavior for one app.
    ///
    /// - parameter notification: The notification.
    @objc func behaviorDidChangeForApp(notification: Notification) {
        func updateIfCurrent(id: String, behavior: AppBehavior) {
            if id == currentID {
                adaptModeForApp(withId: id)
                currentAppViewController.updateBehaviorForCurrentApp(behavior)
            }
        }
        
        guard let userInfo = notification.userInfo,
            let info = BehaviorController.behaviorDidChangeUserInfoFor(dict: userInfo) else { return }
        setBehaviorForApp(id: info.id, behavior: info.behavior, url: info.url)
        switch notification.object! {
        case is CurrentAppViewController:
            adaptModeForApp(withId: info.id)
        default:
            updateIfCurrent(id: info.id, behavior: info.behavior)
        }
    }
    
    func switchMethodDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo, let method = userInfo["method"] as? SwitchMethod else { return }
        switchMethod = method
        switch method {
        case .window:
            startObservingBehaviorDidChange()
            adaptModeForApp(withId: currentID)
        case .key:
            stopObservingBehaviorDidChange()
            currentMode = BehaviorManager.default.defaultKeyboardMode
            changeKeyboard(mode: currentMode)
        }
    }
    
    func defaultModeController(_ controller: DefaultModeViewController, didChangeModeTo mode: KeyboardMode) {
        switch switchMethod {
        case .window:
            adaptModeForApp(withId: currentID)
        case .key:
            changeKeyboard(mode: mode)
            currentMode = mode
        }
    }
    
    /// Disable this session's Fluor instance in order to prevent it from messing when potential other sessions' ones.
    ///
    /// - Parameter notification: The notification.
    @objc private func sessionDidBecomeInactive(notification: Notification) {
        switch onLaunchKeyboardMode {
        case .apple:
            setFnKeysToAppleMode()
        default:
            setFnKeysToOtherMode()
        }
        resignAsObserver()
    }
    
    
    /// Reenable this session's Fluor instance.
    ///
    /// - Parameter notification: The notification.
    @objc private func sessionDidBecomeActive(notification: Notification) {
        changeKeyboard(mode: currentMode)
        applyAsObserver()
    }
    
    /// Set function key behavior in the current running app view.
    ///
    /// - parameter app: The running app.
    /// - parameter id:  The app's bundle id.
    private func updateAppBehaviorViewFor(app: NSRunningApplication, id: String) {
        currentAppViewController.setCurrent(app: app, behavior: BehaviorManager.default.behaviorForApp(id: id))
    }
    
    /// Set the behavior for an application.
    ///
    /// - parameter id:       The application's bundle id.
    /// - parameter behavior: The new behavior.
    /// - parameter url:      The application's bundle url.
    private func setBehaviorForApp(id: String, behavior: AppBehavior, url: URL) {
        BehaviorManager.default.setBehaviorForApp(id: id, behavior: behavior, url: url)
    }
    
    /// Set the function keys' behavior for the given app.
    ///
    /// - parameter id: The app's bundle id.
    private func adaptModeForApp(withId id: String) {
        guard case .window = switchMethod else { return }
        let behavior = BehaviorManager.default.behaviorForApp(id: id)
        let mode = BehaviorManager.default.keyboardStateFor(behavior: behavior)
        guard mode != currentMode else { return }
        currentMode = mode
        changeKeyboard(mode: mode)
}
    
    private func changeKeyboard(mode: KeyboardMode) {
        switch mode {
        case .apple:
            NSLog("Switch to Apple Mode for %@", currentID)
            statusMenuController.statusItem.image = BehaviorManager.default.useLightIcon() ? #imageLiteral(resourceName: "AppleMode") : #imageLiteral(resourceName: "IconAppleMode")
            setFnKeysToAppleMode()
        case .other:
            NSLog("Switch to Other Mode for %@", currentID)
            statusMenuController.statusItem.image = BehaviorManager.default.useLightIcon() ? #imageLiteral(resourceName: "OtherMode") : #imageLiteral(resourceName: "IconOtherMode")
            setFnKeysToOtherMode()
        default:
            return
        }
    }
    
    private func manageKeyPress(event: NSEvent) {
        guard event.modifierFlags.contains(.function), case .key = switchMethod else { return }
        let mode = currentMode.counterPart()
        BehaviorManager.default.defaultKeyboardMode = mode
        changeKeyboard(mode: mode)
        currentMode = mode
    }
    
    func adaptToAccessibilityTrust() {
        if AXIsProcessTrusted() {
            self.isKeySwitchCapable = true
            ensureMonitoringFlagKey()
        } else {
            self.isKeySwitchCapable = false
            stopMonitoringFlagKey()
        }
    }
    
    private func ensureMonitoringFlagKey() {
        guard self.isKeySwitchCapable && self.globalEventManager == nil else { return }
        self.globalEventManager = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: manageKeyPress)
    }
    
    private func stopMonitoringFlagKey() {
        guard let gem = self.globalEventManager else { return }
        NSEvent.removeMonitor(gem)
        self.globalEventManager = nil
    }
    
    /// Pack app's information in a dictionnary suitable for Notification's use.
    ///
    /// - parameter id:       The app's bundle id.
    /// - parameter url:      The app's bundle URL.
    /// - parameter behavior: The app's function keys behavior.
    ///
    /// - returns: A dictionnary usable as Notification's userInfo.
    static func behaviorDidChangeUserInfoConstructor(id: String, url: URL, behavior: AppBehavior, source: NotificationSource? = nil) -> [String: Any] {
        return ["id": id, "url": url, "behavior": behavior, "source": source ?? .undefined]
    }
    
    /// Try to unpack Notification's userInfo with app's information.
    ///
    /// - parameter dict: The userInfo dictionnary provided by a Notification object.
    ///
    /// - returns: A tupple containing all app's information if the userInfo dictionnary contained required keys. Nil otherwise.
    static func behaviorDidChangeUserInfoFor(dict: [AnyHashable: Any]) -> (id: String, url: URL, behavior: AppBehavior, source: NotificationSource)? {
        guard let behavior = dict["behavior"] as? AppBehavior,
            let url = dict["url"] as? URL,
            let id = dict["id"] as? String,
            let source = dict["source"] as? NotificationSource else { return nil }
        return (id, url, behavior, source)
    }
}
