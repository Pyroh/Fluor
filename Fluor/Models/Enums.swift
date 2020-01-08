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
    
    func counterPart() -> FKeyMode {
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
}

@objc enum SwitchMethod: Int {
    case window = 0
    case key
}

enum ItemKind {
    case rule
    case runningApp
    
    var source: NotificationSource {
        switch self {
        case .rule:
            return .rulesWindow
        case .runningApp:
            return .runningAppWindow
        }
    }
}

enum NotificationSource {
    case rulesWindow
    case runningAppWindow
    case mainMenu
    case fnKey
    case undefined
}
