//
//  NotificationHelpers.swift
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

extension Notification.Name {
    public static let BehaviorDidChangeForApp = Notification.Name("BehaviorDidChangeForApp")
    public static let SwitchMethodDidChange = Notification.Name("SwitchMethodDidChange")
    public static let TriggerSectionVisibilityDidChange = Notification.Name("TriggerSectionVisibilityDidChange")
    public static let MenuNeedsToOpen = Notification.Name("MenuNeedsToOpen")
    public static let MenuNeedsToClose = Notification.Name("MenuNeedsToClose")
}

@objc protocol ActiveApplicationDidChangeObserver {
    func activeApplicationDidChangw(notification: Notification)
}

extension ActiveApplicationDidChangeObserver {
    func startObservingActiveApplicationDidChange() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeApplicationDidChangw(notification:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }
    
    func stopObservingActiveApplicationDidChange() {
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }
}

// MARK: -
// MARK: BehaviorDidChange notfication
@objc protocol BehaviorDidChangeObserver {
    func behaviorDidChangeForApp(notification: Notification)
}

extension BehaviorDidChangeObserver {
    func startObservingBehaviorDidChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(behaviorDidChangeForApp(notification:)), name: .BehaviorDidChangeForApp, object: nil)
    }
    func stopObservingBehaviorDidChange() {
        NotificationCenter.default.removeObserver(self, name: .BehaviorDidChangeForApp, object: nil)
    }
}

protocol BehaviorDidChangePoster {
    func postBehaviorDidChangeNotification(id: String, url: URL, behavior: AppBehavior, source: NotificationSource)
}

extension BehaviorDidChangePoster {
    func postBehaviorDidChangeNotification(id: String, url: URL, behavior: AppBehavior, source: NotificationSource = .undefined) {
        let userInfo = ["id": id, "url": url, "behavior": behavior, "source": source] as [String : Any]
        NotificationCenter.default.post(name: .BehaviorDidChangeForApp, object: self, userInfo: userInfo)
    }
}

// MARK: -
// MARK: SwitchMethodDidChange notification
@objc protocol SwitchMethodDidChangeObserver {
    func switchMethodDidChange(notification: Notification)
}

extension SwitchMethodDidChangeObserver {
    func startObservingSwitchMethodDidChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchMethodDidChange(notification:)), name: .SwitchMethodDidChange, object: nil)
    }
    func stopObservingSwitchMethodDidChange() {
        NotificationCenter.default.removeObserver(self, name: .SwitchMethodDidChange, object: nil)
    }
}

protocol SwitchMethodDidChangePoster {
    func postSwitchMethodDidChangeNotification(method: SwitchMethod)
}

extension SwitchMethodDidChangePoster {
    func postSwitchMethodDidChangeNotification(method: SwitchMethod) {
        let userInfo = ["method": method]
        NotificationCenter.default.post(name: .SwitchMethodDidChange, object: self, userInfo: userInfo)
    }
}

// MARK: -
// MARK: TriggerSectionVisibilityDidChange notification
@objc protocol TriggerSectionVisibilityDidChangeObserver {
    func triggerSectionVisibilityDidChange(notification: Notification)
}

extension TriggerSectionVisibilityDidChangeObserver {
    func startObservingTriggerSectionVisibilityDidChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(triggerSectionVisibilityDidChange(notification:)), name: .TriggerSectionVisibilityDidChange, object: nil)
    }
    func stopObservingTriggerSectionVisibilityDidChange() {
        NotificationCenter.default.removeObserver(self, name: .TriggerSectionVisibilityDidChange, object: nil)
    }
}

protocol TriggerSectionVisibilityDidChangePoster {
    func postTriggerSectionVisibilityDidChange(visible: Bool)
}

extension TriggerSectionVisibilityDidChangePoster {
    func postTriggerSectionVisibilityDidChange(visible: Bool) {
        let userInfo = ["visible": visible]
        NotificationCenter.default.post(name: .TriggerSectionVisibilityDidChange, object: self, userInfo: userInfo)
    }
}

// MARK: -
// MARK: Menu control notifications
@objc protocol MenuControlObserver {
    func menuNeedsToOpen(notification: Notification)
    func menuNeedsToClose(notification: Notification)
}

extension MenuControlObserver {
    func startObservingMenuControlNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(menuNeedsToOpen(notification:)), name: .MenuNeedsToOpen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuNeedsToClose(notification:)), name: .MenuNeedsToClose, object: nil)

    }
    func stopObservingSwitchMenuControlNotification() {
        NotificationCenter.default.removeObserver(self, name: .MenuNeedsToOpen, object: nil)
        NotificationCenter.default.removeObserver(self, name: .MenuNeedsToClose, object: nil)
    }
}

protocol MenuControlPoster {
    func postMenuNeedsToOpenNotification()
    func postMenuNeedsToCloseNotification(animated: Bool)
}

extension MenuControlPoster {
    func postMenuNeedsToOpenNotification() {
        NotificationCenter.default.post(name: .MenuNeedsToOpen, object: self)
    }
    
    func postMenuNeedsToCloseNotification(animated: Bool = true) {
        let userInfo = ["animated": animated]
        NotificationCenter.default.post(name: .MenuNeedsToClose, object: self, userInfo: userInfo)
    }
}
