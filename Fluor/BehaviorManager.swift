//
//  BehaviorManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Foundation

class BehaviorManager {
    static let `default`: BehaviorManager = BehaviorManager()
    
    private(set) var isAppleDefaultBehavior: Bool
    private var behaviorDict: [String: AppBehavior]
    
    private init() {
        isAppleDefaultBehavior = false
        behaviorDict = [:]
        
        loadPrefs()
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
    
    private func loadPrefs() {
        
    }
    
    private func synchronizePrefs() {
        
    }
}
