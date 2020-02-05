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
class BehaviorManager {
    
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
    
    private var behaviorDict: [String: (behavior: AppBehavior, url: URL)] = [:]
    private let defaults = UserDefaults.standard
    
    private init() {
        loadPrefs()
    }
    
    /// Retrieve all registred behavior stored in the user's defaults.
    ///
    /// - returns: An array containing all the behavior packed in `RuleItem` objects.
    func retrieveRules() -> [RuleItem] {
        guard let rawRules = defaults.array(forKey: UserDefaultsKeyName.appRules.rawValue) as? [[String: Any]] else { return [] }
        var rules = [RuleItem]()
        rawRules.forEach({ (dict) in
            guard let appId = dict["id"] as? String, let appBehavior = dict["behavior"] as? Int, let appPath = dict["path"] as? String else { return }
            let appURL = URL(fileURLWithPath: appPath)
            let appIcon = NSWorkspace.shared.icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: AppBehavior(rawValue: appBehavior)!, kind: .rule)
            rules.append(item)
        })
        return rules
    }
    
    
    /// Return the behavior for the given application.
    ///
    /// - parameter id: The application's bundle id.
    ///
    /// - returns: The behavior for the application.
    func behaviorForApp(id: String) -> AppBehavior {
        return behaviorDict[id]?.behavior ?? .inferred
    }
    
    
    /// Change the application of the given bundle id and bundle url.
    ///
    /// - parameter id:       The application's bundle id.
    /// - parameter behavior: The new application's behavior.
    /// - parameter url:      The application's bundle url.
    func setBehaviorForApp(id: String, behavior: AppBehavior, url: URL) {
        var change = false
        if behavior == .inferred {
            behaviorDict.removeValue(forKey: id)
            change = true
        } else if let previousBehavior = behaviorDict[id]?.behavior {
            if previousBehavior != behavior {
                behaviorDict[id]?.behavior = behavior
                change = true
            }
        } else {
            behaviorDict[id] = (behavior, url)
            change = true
        }
        if change { synchronizeRules() }
    }
    
    
    /// Get the function key state according to globals preferences.
    ///
    /// - returns: The current keyboard state.
    func getCurrentFKeyMode() -> FKeyMode {
        switch FKeyManager.getCurrentFKeyMode() {
        case .success(let mode):
            return mode
        case .failure(let error):
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
            return defaultFKeyMode
        case .apple:
            return .apple
        case .other:
            return .other
        }
    }
    
    /// Load the defaults.
    private func loadPrefs() {
        guard let arr = defaults.array(forKey: UserDefaultsKeyName.appRules.rawValue) else { return }
        for item in arr {
            guard let dict = item as? [String: Any], let key = dict["id"] as? String, let behaviorRawValue = dict["behavior"] as? Int, let behavior = AppBehavior(rawValue: behaviorRawValue), let path = dict["path"] as? String else { return }
            let url = URL(fileURLWithPath: path)
            behaviorDict[key] = (behavior, url)
        }
    }
    
    /// Synchronize and write the defaults from altered data held by this `BehaviorManager` instance.
    private func synchronizeRules() {
        var arr = [Any]()
        behaviorDict.forEach { (key: String, value: (behavior: AppBehavior, url: URL)) in
            let dict: [String: Any] = ["id": key, "behavior": value.behavior.rawValue, "path": value.url.path]
            arr.append(dict)
        }
        defaults.set(arr, forKey: UserDefaultsKeyName.appRules.rawValue)
    }
}
