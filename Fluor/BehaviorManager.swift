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
    struct DefaultsKeys {
        static let defaultState = "DefaultKeyboardState"
        static let appRules = "AppRules"
        static let resetStateOnQuit = "ResetModeOnQuit"
        static let sameStateAsBeforeStartup = "SameStateAsBeforeStartup"
        static let onQuitState = "OnQuitState"
    }
    
    
    /// The defaut behavior manager. It's a singleton.
    static let `default`: BehaviorManager = BehaviorManager()
    
    var defaultKeyboardState: KeyboardState
    
    private var behaviorDict: [String: (behavior: AppBehavior, url: URL)]
    private let defaults = UserDefaults.standard
    
    private init() {
        self.defaultKeyboardState = .apple
        self.behaviorDict = [:]
        
        loadPrefs()
    }
    
    
    /// Retrieve all registred behavior stored in the user's defaults.
    ///
    /// - returns: An array containing all the behavior packed in `RuleItem` objects.
    func retrieveRules() -> [RuleItem] {
        guard let rawRules = defaults.array(forKey: DefaultsKeys.appRules) as? [[String: Any]] else { return [] }
        var rules = [RuleItem]()
        rawRules.forEach({ (dict) in
            let appId = dict["id"] as! String
            let appBehavior = dict["behavior"] as! Int - 1
            let appPath = dict["path"] as! String
            let appURL = URL(fileURLWithPath: appPath)
            let appIcon = NSWorkspace.shared().icon(forFile: appPath)
            let appName = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String ?? appURL.deletingPathExtension().lastPathComponent
            let item = RuleItem(id: appId, url: appURL, icon: appIcon, name: appName, behavior: appBehavior)
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
    func getActualStateAccordingToPreferences() -> KeyboardState {
        switch getCurrentFnKeyState() {
        case AppleMode:
            return .apple
        case OtherMode:
            return .other
        default:
            return .error
        }
    }
    
    
    /// Return the keyboard state for the given behavior based on the actual keyboard state.
    ///
    /// - parameter behavior: The behavior.
    ///
    /// - returns: The keyboard state.
    func keyboardStateFor(behavior: AppBehavior) -> KeyboardState {
        switch behavior {
        case .inferred:
            return defaultKeyboardState
        case .apple:
            return .apple
        case .other:
            return .other
        }
    }
    
    
    /// Read the defaults and tell whether or not Fluor should change the state of the keyboard when quitting.
    ///
    /// - returns: `true` if Fluor should change the state. `false` otherwise.
    func shouldRestoreStateOnQuit() -> Bool {
        return defaults.bool(forKey: DefaultsKeys.resetStateOnQuit)
    }
    
    
    /// Read the defaults and tell whether or not Fluor should restore the pre-launch state of the keyboard before quitting.
    ///
    /// - returns: `true` if Fluor should restore the original state. `false` otherwise.
    func shouldRestorePreviousState() -> Bool {
        return defaults.bool(forKey: DefaultsKeys.sameStateAsBeforeStartup)
    }
    
    
    /// Read the defaults and tell which keyboard state Fluor must set on quit. If it's not asked to restore the original state.
    ///
    /// - returns: The state Fluor should set on quit.
    func onQuitState() -> KeyboardState {
        return KeyboardState(rawValue: defaults.integer(forKey: DefaultsKeys.onQuitState))!
    }
    
    
    /// Load the defaults.
    private func loadPrefs() {
        let factoryDefaults: [String: Any] = [DefaultsKeys.defaultState: KeyboardState.apple.rawValue, DefaultsKeys.appRules: [Any](), DefaultsKeys.resetStateOnQuit: false, DefaultsKeys.sameStateAsBeforeStartup: true, DefaultsKeys.onQuitState: KeyboardState.apple.rawValue]
        defaults.register(defaults: factoryDefaults)
        
        defaultKeyboardState = KeyboardState(rawValue: defaults.integer(forKey: DefaultsKeys.defaultState))!
        
        guard let arr = defaults.array(forKey: DefaultsKeys.appRules) else { return }
        for item in arr {
            let dict = item as! [String: Any]
            let key = dict["id"] as! String
            let behavior = AppBehavior(rawValue: dict["behavior"] as! Int)!
            let path = dict["path"] as! String
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
        defaults.set(arr, forKey: DefaultsKeys.appRules)
    }
}
