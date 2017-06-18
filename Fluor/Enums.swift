//
//  Enums.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

@objc enum KeyboardMode: Int {
    case apple = 0
    case other
    case error
    
    func counterPart() -> KeyboardMode {
        switch self {
        case .apple: return .other
        case .other: return .apple
        case .error: return .error
        }
    }
}

@objc enum AppBehavior: Int {
    case inferred = 0
    case apple
    case other
}

@objc enum SwitchMethod: Int {
    case windowSwitch = 0
    case fnKey
}
