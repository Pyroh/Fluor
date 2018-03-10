//
//  RulesTableItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

/// Models a rule in the *Rules* and *Running Apps* panels' table view.
class RuleItem: NSObject {
    let id: String
    let url: URL
    @objc let icon: NSImage
    @objc let name: String
    let kind: ItemKind
    @objc dynamic var behavior: AppBehavior
    @objc dynamic let isApp: Bool
    let pid: pid_t?
    
    override var hashValue: Int {
        return url.hashValue
    }
    
    init(id: String, url: URL, icon: NSImage, name: String, behavior: AppBehavior, kind: ItemKind, isApp flag: Bool = true, pid: pid_t? = nil) {
        self.id = id
        self.url = url
        self.icon = icon
        self.name = name
        self.kind = kind
        self.behavior = behavior
        self.isApp = flag
        self.pid = pid
    }
    
    convenience init(fromItem item: RuleItem, withBehavior behavior: AppBehavior, kind: ItemKind) {
        self.init(id: item.id, url: item.url, icon: item.icon, name: item.name, behavior: behavior, kind: kind)
    }
    
    func postChangeNotification() {
        let info = BehaviorController.behaviorDidChangeUserInfoConstructor(id: id, url: url, behavior: behavior)
        let not = Notification(name: .BehaviorDidChangeForApp, object: self, userInfo: info)
        NotificationCenter.default.post(not)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object else { return false }
        switch object {
        case let item as RuleItem:
            if let pid = self.pid, let opid = item.pid { return pid == opid }
            return self.id == item.id && item.url == item.url
        case let pid as pid_t:
            return self.pid == pid
        case let id as String:
            return self.id == id
        case let url as URL:
            return self.url == url
        default:
            return false
        }
    }
}


