//
//  Enums.swift
//  
//  Fluor
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import DefaultsWrapper

@objc enum FKeyMode: Int {
    case media = 0
    case function
    
    var behavior: AppBehavior {
        switch self {
        case .media:
            return .media
        case .function:
            return .function
        }
    }
    
    var counterPart: FKeyMode {
        switch self {
        case .media: return .function
        case .function: return .media
        }
    }
    
    var label: String {
        switch self {
        case .media:
            return NSLocalizedString("Media keys", comment: "")
        case .function:
            return NSLocalizedString("Function keys", comment: "")
        }
    }
}

@objc enum AppBehavior: Int {
    case inferred = 0
    case media
    case function
    
    var counterPart: AppBehavior {
        switch self {
        case .media:
            return .function
        case .function:
            return .media
        default:
            return .inferred
        }
    }
    
    var label: String {
        switch self {
        case .inferred:
            return NSLocalizedString("Same as default", comment: "")
        case .media:
            return NSLocalizedString("Media keys", comment: "")
        case .function:
            return NSLocalizedString("Function keys", comment: "")
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

struct UserNotificationEnablement: OptionSet {
    let rawValue: Int
    
    static let appSwitch: Self = .init(rawValue: 1 << 0)
    static let appKey: Self = .init(rawValue: 1 << 1)
    static let globalKey: Self = .init(rawValue: 1 << 2)
    
    static let all: Self = [.appSwitch, .appKey, .globalKey]
    static let none: Self = []
    
    static func from(_ vc: UserNotificationEnablementViewController) -> Self {
        guard !vc.everytime else { return .all }
        return Self.none
            .union(vc.activeAppSwitch ? .appSwitch : .none)
            .union(vc.activeAppFnKey ? .appKey : .none)
            .union(vc.globalFnKey ? .globalKey : .none)
    }
    
    func apply(to vc: UserNotificationEnablementViewController) {
        if self == .all {
            vc.everytime = true
            vc.activeAppSwitch = true
            vc.activeAppFnKey = true
            vc.globalFnKey = true
        } else if self == .none {
            vc.everytime = false
            vc.activeAppSwitch = false
            vc.activeAppFnKey = false
            vc.globalFnKey = false
        } else {
            vc.everytime = false
            vc.activeAppSwitch = self.contains(.appSwitch)
            vc.activeAppFnKey = self.contains(.appKey)
            vc.globalFnKey = self.contains(.globalKey)
        }
    }
}
