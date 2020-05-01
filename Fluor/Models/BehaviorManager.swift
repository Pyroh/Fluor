//
//  BehaviorManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa
import DefaultsWrapper

extension UserDefaultsKeyName {
    static let userHasAlreadyAnsweredAccessibility: UserDefaultsKeyName = "HasAlreadyRefusedAccessibility"
    static let keyboardMode: UserDefaultsKeyName = "DefaultKeyboardMode"
    static let appRules: UserDefaultsKeyName = "AppRules"
    static let restoreStateOnQuit: UserDefaultsKeyName = "ResetModeOnQuit"
    static let restoreStateAsBeforeStartup: UserDefaultsKeyName = "SameStateAsBeforeStartup"
    static let onQuitState: UserDefaultsKeyName = "OnQuitState"
    static let disabledOnLunch: UserDefaultsKeyName = "OnLaunchDisabled"
    static let switchMethod: UserDefaultsKeyName = "DefaultSwitchMethod"
    static let useLightIcon: UserDefaultsKeyName = "UseLightIcon"
    static let showAllRunningProcesses: UserDefaultsKeyName = "ShowAllProcesses"
    static let fnKeyMaximumDelay: UserDefaultsKeyName = "FNKeyReleaseMaximumDelay"
    static let lastRunVersion: UserDefaultsKeyName = "LastRunVersion"
    static let hideSwitchMethod: UserDefaultsKeyName = "HideSwitchMethod"
}

/// This class holds all per-application keyboard behaviors.
/// It also takes care of NSUserDefaults reading and synchronizing.
class BehaviorManager: BehaviorDidChangePoster {
    
    /// The defaut behavior manager.
    static let `default`: BehaviorManager = BehaviorManager()
    
    @Defaults(key: .keyboardMode, defaultValue: .apple)
    var defaultFKeyMode: FKeyMode
    
    @Defaults(key: .switchMethod, defaultValue: .window)
    var switchMethod: SwitchMethod
    
    @Defaults(key: .hideSwitchMethod, defaultValue: false)
    var hideSwitchMethod: Bool
    
    @Defaults(key: .lastRunVersion, defaultValue: "unknown")
    var lastRunVersion: String
    
    @Defaults(key: .restoreStateOnQuit, defaultValue: false)
    var shouldRestoreStateOnQuit: Bool
    
    @Defaults(key: .restoreStateAsBeforeStartup, defaultValue: false)
    var shouldRestorePreviousState: Bool 
    
    @Defaults(key: .onQuitState, defaultValue: .apple)
    var onQuitState: FKeyMode
    
    @Defaults(key: .disabledOnLunch, defaultValue: false)
    var isDisabled: Bool
    
    @Defaults(key: .useLightIcon, defaultValue: false)
    var useLightIcon: Bool
    
    @Defaults(key: .showAllRunningProcesses, defaultValue: false)
    var showAllRunningProcesses: Bool
    
    @Defaults(key: .userHasAlreadyAnsweredAccessibility, defaultValue: false)
    var hasAlreadyAnsweredAccessibility: Bool 
    
    @Defaults(key: .fnKeyMaximumDelay, defaultValue: 280)
    var fnKeyMaximumDelay: TimeInterval
    
    private(set) var rules: Set<Rule> = []
    private var behaviorDict: [String: AppBehavior] = [:]
    private let defaults = UserDefaults.standard
    
    private init() {
        self.loadRules()
    }
    
    func propagate(behavior: AppBehavior, forApp id: String, at url: URL, from source: NotificationSource) {
        guard self.behaviorDict[id] != behavior else { return }
        self.setBehaviorForApp(id: id, behavior: behavior, url: url)
        self.postBehaviorDidChangeNotification(id: id, url: url, behavior: behavior, source: source)
    }
    
    /// Return the behavior for the given application.
    ///
    /// - parameter id: The application's bundle id.
    ///
    /// - returns: The behavior for the application.
    func behaviorForApp(id: String) -> AppBehavior {
        return behaviorDict[id] ?? .inferred
    }
    
    
    /// Change the application of the given bundle id and bundle url.
    ///
    /// - parameter id:       The application's bundle id.
    /// - parameter behavior: The new application's behavior.
    /// - parameter url:      The application's bundle url.
    func setBehaviorForApp(id: String, behavior: AppBehavior, url: URL) {
        var change = false
        if behavior == .inferred {
            self.behaviorDict.removeValue(forKey: id)
            guard let index = self.rules.firstIndex(where: { $0.url == url }) else { fatalError() }
            self.rules.remove(at: index)
            change = true
        } else if let previousBehavior = self.behaviorDict[id] {
            if previousBehavior != behavior {
                self.behaviorDict[id] = behavior
                guard let rule = self.rules.first(where: { $0.url == url }) else { fatalError() }
                rule.behavior = behavior
                change = true
            }
        } else {
            behaviorDict[id] = behavior
            self.rules.insert(.init(id: id, url: url, behavior: behavior))
            change = true
        }
        if change { synchronizeRules() }
    }
    
    
    /// Get the function key state according to globals preferences.
    ///
    /// - returns: The current keyboard state.
    func getCurrentFKeyMode() -> FKeyMode {
        FKeyManager.getCurrentFKeyMode().getOrFailWith { (error) -> Never in
            AppErrorManager.terminateApp(withReason: error.localizedDescription)
        }
    }
    
    
    /// Return the keyboard state for the given behavior based on the actual keyboard state.
    ///
    /// - parameter behavior: The behavior.
    ///
    /// - returns: The keyboard state.
    func keyboardStateFor(behavior: AppBehavior) -> FKeyMode {
        switch behavior {
        case .inferred:
            return self.defaultFKeyMode
        case .apple:
            return .apple
        case .other:
            return .other
        }
    }
    
    /// Load the defaults.
    private func loadRules() {
        if let rules: Set<Rule> = self.defaults.convertible(forKey: UserDefaultsKeyName.appRules.rawValue) {
            self.rules = rules
            self.behaviorDict = .init(uniqueKeysWithValues: rules.map { ($0.id, $0.behavior) })
        }
    }
    
    /// Synchronize and write the defaults from altered data held by this `BehaviorManager` instance.
    private func synchronizeRules() {
        self.defaults.set(self.rules, forKey: UserDefaultsKeyName.appRules.rawValue)
    }
}
