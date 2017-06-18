//
//  Notification-Extension.swift
//  Fluor
//
//  Created by Pierre TACCHI on 14/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let BehaviorDidChangeForApp = Notification.Name("kBehaviorDidChangeForApp")
    public static let RuleDidChangeForApp = Notification.Name("kRuleDidChangeForApp")
    public static let SwitchMethodDidChange = Notification.Name("kSwitchMethodDidChange")
}

/// Behavior did change for app notification handler
@objc protocol BehaviorDidChangeHandler {
    @objc func behaviorDidChangeForApp(notification: Notification)
}

extension BehaviorDidChangeHandler {
    func startObservingBehaviorDidChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(behaviorDidChangeForApp(notification:)), name: Notification.Name.BehaviorDidChangeForApp, object: nil)
    }
    func stopObservingBehaviorDidChange() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.BehaviorDidChangeForApp, object: nil)
    }
}

/// Rule did change for app notification handler
protocol RuleDidChangeHandler {
    var ruleSelector: Selector { get }
    
    func startObservingRuleDidChange()
    func stopObservingRuleDidChange()
}

extension RuleDidChangeHandler {
    func startObservingRuleDidChange() {
        NotificationCenter.default.addObserver(self, selector: ruleSelector, name: Notification.Name.RuleDidChangeForApp, object: nil)
    }
    func stopObservingRuleDidChange() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.RuleDidChangeForApp, object: nil)
    }
}

@objc protocol SwitchMethodDidChangeHandler {
    @objc func switchMethodDidChange(notification: Notification)
}

extension SwitchMethodDidChangeHandler {
    func startObservingSwitchMethodDidChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchMethodDidChange(notification:)), name: Notification.Name.SwitchMethodDidChange, object: nil)
    }
    func stopObservingSwitchMethodDidChange() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SwitchMethodDidChange, object: nil)
    }
}
