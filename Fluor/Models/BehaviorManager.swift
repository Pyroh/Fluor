//
//  BehaviorManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

/// This class holds all per-application keyboard behaviors.
/// It also takes care of NSUserDefaults reading and synchronizing.
class BehaviorManager {
    struct DefaultKey: RawRepresentable {
        let rawValue: String
        
        static let userHasAlreadyAnsweredAccessibility = BehaviorManager.DefaultKey(rawValue: "HasAlreadyRefusedAccessibility")
        static let keyboardMode = BehaviorManager.DefaultKey(rawValue: "DefaultKeyboardMode")
        static let appRules = BehaviorManager.DefaultKey(rawValue: "AppRules")
        static let restoreStateOnQuit = BehaviorManager.DefaultKey(rawValue: "ResetModeOnQuit")
        static let restoreStateAsBeforeStartup = BehaviorManager.DefaultKey(rawValue: "SameStateAsBeforeStartup")
        static let onQuitState = BehaviorManager.DefaultKey(rawValue: "OnQuitState")
        static let disabledOnLunch = BehaviorManager.DefaultKey(rawValue: "OnLaunchDisabled")
        static let switchMethod = BehaviorManager.DefaultKey(rawValue: "DefaultSwitchMethod")
        static let useLightIcon = BehaviorManager.DefaultKey(rawValue: "UseLightIcon")
        static let showAllRunningProcesses = BehaviorManager.DefaultKey(rawValue: "ShowAllProcesses")
        static let fnKeyMaximumDelay = BehaviorManager.DefaultKey(rawValue: "FNKeyReleaseMaximumDelay")
        static let lastRunVersion = BehaviorManager.DefaultKey(rawValue: "LastRunVersion")
        static let hideSwitchMethod = BehaviorManager.DefaultKey(rawValue: "HideSwitchMethod")
    }
    
    /// The defaut behavior manager. It's a singleton.
    static let `default`: BehaviorManager = BehaviorManager()
    
    @DefaultValue(key: DefaultKey.keyboardMode, defaultValue: .apple)
    var defaultFKeyMode: FKeyMode
    
    @DefaultValue(key: DefaultKey.switchMethod, defaultValue: .window)
    var switchMethod: SwitchMethod
    
    @DefaultValue(key: DefaultKey.hideSwitchMethod, defaultValue: false)
    var hideSwitchMethod: Bool
    
    @DefaultValue(key: DefaultKey.lastRunVersion, defaultValue: "unknown")
    var lastRunVersion: String
    
    @DefaultValue(key: DefaultKey.restoreStateOnQuit, defaultValue: false)
    var shouldRestoreStateOnQuit: Bool
    
    @DefaultValue(key: DefaultKey.restoreStateAsBeforeStartup, defaultValue: false)
    var shouldRestorePreviousState: Bool 
    
    @DefaultValue(key: DefaultKey.onQuitState, defaultValue: .apple)
    var onQuitState: FKeyMode
    
    @DefaultValue(key: DefaultKey.disabledOnLunch, defaultValue: false)
    var isDisabled: Bool
    
    @DefaultValue(key: DefaultKey.useLightIcon, defaultValue: false)
    var useLightIcon: Bool
    
    @DefaultValue(key: DefaultKey.showAllRunningProcesses, defaultValue: false)
    var showAllRunningProcesses: Bool
    
    @DefaultValue(key: DefaultKey.userHasAlreadyAnsweredAccessibility, defaultValue: false)
    var hasAlreadyAnsweredAccessibility: Bool 
    
    @DefaultValue(key: DefaultKey.fnKeyMaximumDelay, defaultValue: 280)
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
        guard let rawRules = defaults.array(forKey: DefaultKey.appRules.rawValue) as? [[String: Any]] else { return [] }
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
    func getActualStateAccordingToPreferences() -> FKeyMode {
        switch FKeyManager.getCurrentFKeyMode() {
        case .success(let mode):
            return mode
        case .failure(_):
            fatalError()
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
        guard let arr = defaults.array(forKey: DefaultKey.appRules.rawValue) else { return }
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
        defaults.set(arr, forKey: DefaultKey.appRules.rawValue)
    }
}
