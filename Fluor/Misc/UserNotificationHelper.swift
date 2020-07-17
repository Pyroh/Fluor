//
//  UserNotificationHelper.swift
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
import UserNotifications

enum UserNotificationHelper {
    static var holdNextModeChangedNotification: Bool = false
    
    static func askUserAtLaunch() {
        guard !AppManager.default.hideNotificationAuthorizationPopup else { return }
        if #available(OSX 10.14, *) {
            askOnStartupIfNeeded()
        } else {
            legacyAskOnStartupIfNeededStartup()
        }
    }
    
    static func askUser(then action: @escaping (Bool) -> ()) {
        if #available(OSX 10.14, *) {
            askIfNeeded(then: action)
        } else {
            legacyAskIfNeeded(then: action)
        }
    }
    
    static func sendModeChangedTo(_ mode: FKeyMode) {
        guard !holdNextModeChangedNotification else {
            holdNextModeChangedNotification.toggle()
            return
        }
        guard AppManager.default.userNotificationEnablement.contains(.appSwitch) else { return }
        let title = NSLocalizedString("F-Keys mode changed", comment: "")
        let message = mode.label
        send(title: title, message: message)
    }
    
    static func sendFKeyChangedAppBehaviorTo(_ behavior: AppBehavior, appName: String) {
        guard AppManager.default.userNotificationEnablement.contains(.appKey) else { return }
        let title = String(format: NSLocalizedString("F-Keys mode changed for %@", comment: ""), appName)
        let message = behavior.label
        send(title: title, message: message)
    }
    
    static func sendGlobalModeChangedTo(_ mode: FKeyMode) {
        guard AppManager.default.userNotificationEnablement.contains(.globalKey) else { return }
        let title = NSLocalizedString("Default mode changed", comment: "")
        let message = mode.label
        send(title: title, message: message)
    }
    
    private static func send(title: String, message: String) {
        if #available(OSX 10.14, *) {
            sendNotification(withTitle: title, andMessage: message)
        } else {
            legacySendNotification(withMessage: title, andMessage: message)
        }
    }
    
    @available(OSX 10.14, *)
    private static func sendNotification(withTitle title: String, andMessage msg: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = msg
    
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }
    
    private static func legacySendNotification(withMessage title: String, andMessage msg: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = msg
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    static func ifAuthorized(perform action: @escaping () -> (), else unauthorizedAction: @escaping () -> ()) {
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    guard settings.authorizationStatus == .authorized else { return unauthorizedAction() }
                    action()
                }
            }
        } else {
            guard AppManager.default.sendLegacyUserNotifications else { return unauthorizedAction() }
            action()
        }
    }
    
    @available(OSX 10.14, *)
    private static func askOnStartupIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                guard settings.authorizationStatus != .denied, settings.authorizationStatus != .authorized else { return }
                guard settings.authorizationStatus != .authorized else { return }
                
                let alert = makeAlert(suppressible: true)
                let avc = makeAccessoryView()
                alert.buttons.first?.bind(.enabled, to: avc, withKeyPath: "canEnableNotifications", options: nil)
                alert.accessoryView = avc.view
                
                NSApp.activate(ignoringOtherApps: true)
                let result = alert.runModal()
                
                if result == .alertFirstButtonReturn {
                    UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (isAuthorized, err) in
                        DispatchQueue.main.async {
                            if let error = err, isAuthorized {
                                AppErrorManager.showError(withReason: error.localizedDescription)
                            }
                            if isAuthorized {
                                AppManager.default.userNotificationEnablement = .from(avc)
                            } else {
                                AppManager.default.userNotificationEnablement = .none
                            }
                        }
                    }
                } else {
                    AppManager.default.userNotificationEnablement = .none
                }
                AppManager.default.hideNotificationAuthorizationPopup = alert.suppressionButton?.state == .on
            }
        }
    }
    
    private static func legacyAskOnStartupIfNeededStartup() {
        guard !AppManager.default.sendLegacyUserNotifications else { return }
        let alert = makeAlert(suppressible: true)
        let avc = makeAccessoryView()
        alert.buttons.first?.bind(.enabled, to: avc, withKeyPath: "canEnableNotifications", options: nil)
        alert.accessoryView = avc.view
        
        NSApp.activate(ignoringOtherApps: true)
        let result = alert.runModal()
        
        if result == .alertFirstButtonReturn {
            AppManager.default.sendLegacyUserNotifications = true
            AppManager.default.userNotificationEnablement = .from(avc)
        }
    }
    
    @available(OSX 10.14, *)
    private static func askIfNeeded(then action: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                guard settings.authorizationStatus != .authorized else { return action(true) }
                if settings.authorizationStatus == .denied {
                    if retryOnDenied() {
                        askIfNeeded(then: action)
                    } else {
                        action(false)
                    }
                } else {
                    let alert = makeAlert()
                    NSApp.activate(ignoringOtherApps: true)
                    let result = alert.runModal()
                    
                    guard result == .alertFirstButtonReturn else { return action(false) }
                    UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (isAuthorized, err) in
                        DispatchQueue.main.async {
                            if let error = err, isAuthorized {
                                AppErrorManager.showError(withReason: error.localizedDescription)
                            }
                            action(isAuthorized)
                        }
                    }
                }
            }
        }
    }
    
    private static func legacyAskIfNeeded(then action: (Bool) -> ()) {
        guard AppManager.default.sendLegacyUserNotifications else { return }
        let alert = makeAlert()
        NSApp.activate(ignoringOtherApps: true)
        let result = alert.runModal()
        action(result == .alertFirstButtonReturn)
    }
    
    private static func retryOnDenied() -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = NSLocalizedString("Notifications are not allowed from Fluor", comment: "")
        alert.informativeText = "To allow notifications from Fluor follow these steps:"
        alert.addButton(withTitle: NSLocalizedString("I allowed it", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("I won't allow it", comment: ""))
        
        let vc = NSStoryboard(name: .preferences, bundle: nil).instantiateController(withIdentifier: "DebugAuthorization") as? NSViewController
        alert.accessoryView = vc?.view
        
        NSApp.activate(ignoringOtherApps: true)
        let result = alert.runModal()
        
        return result == .alertFirstButtonReturn
    }
    
    private static func makeAlert(suppressible: Bool = false) -> NSAlert {
        let alert = NSAlert()
        alert.icon = NSImage(imageLiteralResourceName: "QuestionMark")
        alert.messageText = NSLocalizedString("Enable notifications ?", comment: "")
        alert.informativeText = NSLocalizedString("Fluor can send notifications when the F-Keys mode changes.", comment: "")
        if suppressible {
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = NSLocalizedString("Don't ask me on startup again", comment: "")
            alert.suppressionButton?.state = .off
        }
        alert.addButton(withTitle: NSLocalizedString("Enable notfications", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Don't enable notifications", comment: ""))
        
        return alert
    }
    
    private static func makeAccessoryView() -> UserNotificationEnablementViewController {
        let avc = UserNotificationEnablementViewController.instantiate()
        avc.isShownInAlert = true
        
        return avc
    }
}

