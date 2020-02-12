//
//  RulesTableItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa
import DefaultsWrapper

class Item: NSObject, Identifiable {
    class var notificationSource: NotificationSource { .undefined }
    
    let id: String
    @objc let url: URL
    @objc dynamic var behavior: AppBehavior {
        didSet {
            BehaviorManager.default.propagate(behavior: self.behavior, forApp: self.id, at: self.url, from: Self.notificationSource)
        }
    }
    
    @objc var icon: NSImage { NSWorkspace.shared.icon(forFile: self.url.path) }
    @objc var name: String { Bundle(path: self.url.path)?.localizedInfoDictionary?["CFBundleName"] as? String ?? self.url.deletingPathExtension().lastPathComponent }
    
    override var hash: Int {
        self.url.hashValue
    }
    
    init(id: String, url: URL, behavior: AppBehavior) {
        self.id = id
        self.url = url
        self.behavior = behavior
    }
}

final class RunningApp: Item, BehaviorDidChangeObserver {
    override class var notificationSource: NotificationSource { .runningApp }
    
    let pid: pid_t
    @objc let isApp: Bool
    
    override var hash: Int {
        Int(self.pid)
    }
    
    init(id: String, url: URL, behavior: AppBehavior, pid: pid_t, isApp: Bool) {
        self.pid = pid
        self.isApp = isApp
        
        super.init(id: id, url: url, behavior: behavior)
        
        self.startObservingBehaviorDidChange()
    }
    
    deinit {
        self.stopObservingBehaviorDidChange()
    }
    
    // MARK: BehaviorDidChangeObserver
    func behaviorDidChangeForApp(notification: Notification) {
        guard let id = notification.userInfo?["id"] as? String, self.id == id,
            let appBehavior = notification.userInfo?["behavior"] as? AppBehavior else { return }
        self.behavior = appBehavior
    }
}


final class Rule: Item, UserDefaultsConvertible {
    override class var notificationSource: NotificationSource { .rule }
    
    override var hash: Int {
        self.url.hashValue
    }
    
    // MARK: UserDefaultsConvertible
    
    func convertedObject() -> [String: Any] {
        ["id": self.id, "path": self.url.path, "behavior": self.behavior.rawValue]
    }
    
    static func instanciate(from object: [String: Any]) -> Rule? {
        guard let id = object["id"] as? String, let path = object["path"] as? String, let rawBehavior = object["behavior"] as? Int, let behavior = AppBehavior(rawValue: rawBehavior) else { return nil }
        let url = URL(fileURLWithPath: path)
        return Rule(id: id, url: url, behavior: behavior)
    }
}
