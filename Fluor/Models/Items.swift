//
//  RulesTableItem.swift
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

import Cocoa
import DefaultsWrapper

class Item: NSObject, Identifiable {
    var notificationSource: NotificationSource { .undefined }
    
    let id: String
    @objc let url: URL
    @objc dynamic var behavior: AppBehavior 
    
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
    override var notificationSource: NotificationSource { .runningApp }
    
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
    override var notificationSource: NotificationSource { .rule }
    
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
