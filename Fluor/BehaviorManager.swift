//
//  BehaviorManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class BehaviorManager {
    struct DefaultsKeys {
        static let defaultState = "DefaultKeyboardState"
        static let appRules = "AppRules"
        static let resetStateOnQuit = "ResetModeOnQuit"
        static let sameStateAsBeforeStartup = "SameStateAsBeforeStartup"
        static let onQuitState = "OnQuitState"
    }
    
    static let `default`: BehaviorManager = BehaviorManager()
    
    var defaultKeyboardState: KeyboardState
    
    private var behaviorDict: [String: (behavior: AppBehavior, url: URL)]
    private let defaults = UserDefaults.standard
    
    private init() {
        defaultKeyboardState = .apple
        behaviorDict = [:]
        
        loadPrefs()
    }
    
    func retrieveRules() -> [RulesTableItem] {
        guard let rawRules = defaults.array(forKey: DefaultsKeys.appRules) as? [[String: Any]] else { return [] }
        var rules = [RulesTableItem]()
        rawRules.forEach({ (dict) in
            let appId = dict["id"] as! String
            let appBehavior = dict["behavior"] as! Int - 1
            let appPath = dict["path"] as! String
            let appUrl = URL(fileURLWithPath: appPath)
            let appIcon = NSWorkspace.shared().icon(forFile: appPath)
            let appName: String
            if let name = Bundle(path: appPath)?.localizedInfoDictionary?["CFBundleName"] as? String {
                appName = name
            } else {
                appName = appUrl.deletingPathExtension().lastPathComponent
            }
            let item = RulesTableItem(id: appId, url: appUrl, icon: appIcon, name: appName, behavior: appBehavior)
            rules.append(item)
        })
        return rules
    }
    
    func behaviorForApp(id: String) -> AppBehavior {
        return behaviorDict[id]?.behavior ?? .infered
    }
    
    func setBehaviorForApp(id: String, behavior: AppBehavior, url: URL) {
        var change = false
        if behavior == .infered {
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
    
    func keyboardStateFor(behavior: AppBehavior) -> KeyboardState {
        switch behavior {
        case .infered:
            return defaultKeyboardState
        case .apple:
            return .apple
        case .other:
            return .other
        case .negate:
            switch defaultKeyboardState {
            case .apple:
                return .other
            case .other:
                return .apple
            default:
                return .error
            }
        }
    }
    
    func shouldRestoreStateOnQuit() -> Bool {
        return defaults.bool(forKey: DefaultsKeys.resetStateOnQuit)
    }
    
    func shouldRestorePreviousState() -> Bool {
        return defaults.bool(forKey: DefaultsKeys.sameStateAsBeforeStartup)
    }
    
    func onQuitState() -> KeyboardState {
        return KeyboardState(rawValue: defaults.integer(forKey: DefaultsKeys.onQuitState))!
    }
    
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
    
    private func synchronizeRules() {
        var arr = [Any]()
        behaviorDict.forEach { (key: String, value: (behavior: AppBehavior, url: URL)) in
            let dict: [String: Any] = ["id": key, "behavior": value.behavior.rawValue, "path": value.url.path]
            arr.append(dict)
        }
        defaults.set(arr, forKey: DefaultsKeys.appRules)
    }
}
