//
//  RulesTableItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

enum ItemKind {
    case rule
    case runningApp
}


/// Models a rule in the *Rules* panel's table view.
class RuleItem: NSObject {
    let id: String
    let url: URL
    @objc let icon: NSImage
    @objc let name: String
    let kind: ItemKind
    @objc dynamic var behavior: AppBehavior
    @objc dynamic let isApp: Bool
    
    init(id: String, url: URL, icon: NSImage, name: String, behavior: AppBehavior, kind: ItemKind, isApp flag: Bool = true) {
        self.id = id
        self.url = url
        self.icon = icon
        self.name = name
        self.kind = kind
        self.behavior = behavior
        self.isApp = flag
    }
    
    convenience init(fromItem item: RuleItem, withBehavior behavior: AppBehavior, kind: ItemKind) {
        self.init(id: item.id, url: item.url, icon: item.icon, name: item.name, behavior: behavior, kind: kind)
    }
    
    func postChangeNotification() {
        let info = BehaviorController.behaviorDidChangeUserInfoConstructor(id: id, url: url, behavior: behavior)
        let not = Notification(name: .BehaviorDidChangeForApp, object: self, userInfo: info)
        NotificationCenter.default.post(not)
    }
}

