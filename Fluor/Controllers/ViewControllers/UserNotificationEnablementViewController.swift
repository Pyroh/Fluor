//
//  UserNotificationEnablementViewController.swift
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
import UserNotifications

final class UserNotificationEnablementViewController: NSViewController, StoryboardInstantiable {
    static var storyboardName: NSStoryboard.Name { .preferences }
    static var sceneIdentifier: NSStoryboard.SceneIdentifier? { "NotificationsEnablement" }
    
    @IBOutlet weak var trailiingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    private var stackViewConstraints: [NSLayoutConstraint] {
        [trailiingConstraint, topConstraint, bottomConstraint, leadingConstraint]
    }
    
    @objc dynamic var activeAppSwitch: Bool = true
    @objc dynamic var activeAppFnKey: Bool = true
    @objc dynamic var globalFnKey: Bool = true
    @objc dynamic var everytime: Bool = true

    @objc dynamic var isShownInAlert: Bool = false
    
    @objc dynamic var canEnableNotifications: Bool {
        everytime || activeAppSwitch || activeAppFnKey || globalFnKey
    }
    
    override func viewWillAppear() {
        self.adaptStackConstraints()
        guard !isShownInAlert, AppManager.default.userNotificationEnablement != .none else {
            if !isShownInAlert { UserNotificationEnablement.none.apply(to: self) }
            return
        }
        UserNotificationHelper.ifAuthorized(perform: {
            AppManager.default.userNotificationEnablement.apply(to: self)
        }) {
            UserNotificationEnablement.none.apply(to: self)
        }
    }
    
    @IBAction func checkBoxDidChange(_ sender: NSButton?) {
        if let tag = sender?.tag, tag == 1 {
            activeAppSwitch = everytime
            activeAppFnKey = everytime
            globalFnKey = everytime
        } else {
            everytime = activeAppSwitch &&  activeAppFnKey &&  globalFnKey
        }
        guard !isShownInAlert else { return }
        self.checkAuthorizations()
    }
    
    private func adaptStackConstraints() {
        stackViewConstraints.forEach { $0.constant = isShownInAlert ? 2 : 0 }
    }
    
    private func checkAuthorizations() {
        UserNotificationHelper.askUser { (isAuthorized) in
            if isAuthorized {
                AppManager.default.userNotificationEnablement = .from(self)
            } else {
                UserNotificationEnablement.none.apply(to: self)
            }
        }
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        guard key == "canEnableNotifications" else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
        
        return .init(["activeAppSwitch", "activeAppFnKey", "globalFnKey", "everytime"])
    }
}
