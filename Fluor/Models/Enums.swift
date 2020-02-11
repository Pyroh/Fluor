//
//  Enums.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

@objc enum FKeyMode: Int {
    case apple = 0
    case other
    
    var behavior: AppBehavior {
        switch self {
        case .apple:
            return .apple
        case .other:
            return .other
        }
    }
    
    var counterPart: FKeyMode {
        switch self {
        case .apple: return .other
        case .other: return .apple
        }
    }
}

@objc enum AppBehavior: Int {
    case inferred = 0
    case apple
    case other
    
    var counterPart: AppBehavior {
        switch self {
        case .apple:
            return .other
        case .other:
            return .apple
        default:
            return .inferred
        }
    }
}

@objc enum SwitchMethod: Int {
    case window = 0
    case hybrid
    case key
}

enum ItemKind {
    case rule
    case runningApp
    
    var source: NotificationSource {
        switch self {
        case .rule:
            return .rule
        case .runningApp:
            return .runningApp
        }
    }
}

enum NotificationSource {
    case rule
    case runningApp
    case mainMenu
    case fnKey
    case behaviorManager
    case undefined
}
