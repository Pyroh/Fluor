//
//  Notification-Extension.swift
//  Fluor
//
//  Created by Pierre TACCHI on 14/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let StateViewDidChangeState = Notification.Name("kStateViewDidChangeState")
    public static let BehaviorDidChangeForApp = Notification.Name("kBehaviorDidChangeForApp")
    public static let RuleDidChangeForApp = Notification.Name("RuleDidChangeForApp")
}
