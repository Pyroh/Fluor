//
//  RulesTableItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class RuleItem: NSObject {
    let id: String
    let url: URL
    let icon: NSImage
    let name: String
    dynamic var behavior: Int {
        didSet {
            postChangeNotification()
        }
    }
    
    init(id: String, url: URL, icon: NSImage, name: String, behavior: Int) {
        self.id = id
        self.url = url
        self.icon = icon
        self.name = name
        self.behavior = behavior
    }
    
    fileprivate func postChangeNotification() {
        let info = StatusMenuController.behaviorDidChangeUserInfoConstructor(id: id, url: url, behavior: AppBehavior(rawValue: behavior + 1)!)
        let not = Notification(name: Notification.Name.BehaviorDidChangeForApp, object: self, userInfo: info)
        NotificationCenter.default.post(not)
    }
}

class RunningAppItem: RuleItem {
    fileprivate override func postChangeNotification() {
        let info = StatusMenuController.behaviorDidChangeUserInfoConstructor(id: id, url: url, behavior: AppBehavior(rawValue: behavior)!)
        let not = Notification(name: Notification.Name.BehaviorDidChangeForApp, object: self, userInfo: info)
        NotificationCenter.default.post(not)
    }
}
