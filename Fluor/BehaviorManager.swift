//
//  BehaviorManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

enum KeyboardState: Int {
    case error
    case apple
    case other
}

struct DefaultsKeys {
    static let appleIsDefaultBehavior = "AppleBehaviorIsDefault"
    static let appRules = "AppRules"
    static let resetStateOnQuit = "ResetBehaviorOnQuit"
    static let onQuitState = "OnQuitBehavior"
}

class BehaviorManager {
    static let `default`: BehaviorManager = BehaviorManager()
    
    static func keyboardStateFor(behavior: AppBehavior, currentState state: KeyboardState) -> KeyboardState {
        if case state = KeyboardState.error { return state }
        
        switch behavior {
        case .infered:
            return `default`.defaultKeyBoardState()
        case .apple:
            return .apple
        case .other:
            return .other
        case .negate:
            switch state {
            case .apple:
                return .other
            case .other:
                return .apple
            default:
                return .error
            }
        }
    }
    
    private var isAppleDefaultBehavior: Bool {
        didSet {
            defaults.set(isAppleDefaultBehavior, forKey: DefaultsKeys.appleIsDefaultBehavior)
        }
    }
    private var behaviorDict: [String: (behavior: AppBehavior, url: URL)]
    private let defaults = UserDefaults.standard
    
    private init() {
        isAppleDefaultBehavior = true
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
    
    func defaultKeyBoardState() -> KeyboardState {
        return isAppleDefaultBehavior ? .apple : .other
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
    
    private func loadPrefs() {
        let factoryDefaults: [String: Any] = [DefaultsKeys.appleIsDefaultBehavior: true, DefaultsKeys.appRules: [Any](), DefaultsKeys.resetStateOnQuit: false, DefaultsKeys.onQuitState: KeyboardState.apple.rawValue]
        defaults.register(defaults: factoryDefaults)
        
        isAppleDefaultBehavior = defaults.bool(forKey: DefaultsKeys.appleIsDefaultBehavior)
        
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
