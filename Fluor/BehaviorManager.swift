//
//  BehaviorManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Foundation

enum KeyboardState {
    case error
    case apple
    case other
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
    
    private var isAppleDefaultBehavior: Bool
    private var behaviorDict: [String: AppBehavior]
    
    private init() {
        isAppleDefaultBehavior = true
        behaviorDict = [:]
        
        loadPrefs()
    }
    
    func defaultKeyBoardState() -> KeyboardState {
        return isAppleDefaultBehavior ? .apple : .other
    }
    
    func behaviorForApp(id: String) -> AppBehavior {
        return behaviorDict[id] ?? .infered
    }
    
    func setBehaviorForApp(id: String, behavior: AppBehavior) {
        var change = false
        if behavior == .infered {
            behaviorDict.removeValue(forKey: id)
            change = true
        } else if let previousBehavior = behaviorDict[id] {
            if previousBehavior != behavior {
                behaviorDict[id] = behavior
                change = true
            }
        } else {
            behaviorDict[id] = behavior
            change = true
        }
        if change { synchronizePrefs() }
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
        
    }
    
    private func synchronizePrefs() {
        
    }
}
