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
