//
//  MenuItemsController.swift
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

class MenuItemsController: NSObject, SwitchMethodDidChangeObserver, TriggerSectionVisibilityDidChangeObserver {
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet var switchMethodViewController: SwitchMethodViewController!
    @IBOutlet var currentAppViewController: CurrentAppViewController!
    @IBOutlet weak var defaultModeViewController: DefaultModeViewController!
    
    override init() {
        super.init()
        self.startObservingSwitchMethodDidChange()
        self.startObservingTriggerSectionVisibilityDidChange()
    }
    
    deinit {
        self.stopObservingSwitchMethodDidChange()
        self.stopObservingTriggerSectionVisibilityDidChange()
    }
    
    func setupController() {
        let switchingPlaceHolder = menu.item(withTag: 1)
        let statePlaceHolder = menu.item(withTag: 3)
        let currentPlaceHolder = menu.item(withTag: 5)
        switchingPlaceHolder?.view = switchMethodViewController.view
        statePlaceHolder?.view = defaultModeViewController.view
        currentPlaceHolder?.view = currentAppViewController.view
        if case SwitchMethod.key = AppManager.default.switchMethod {
            currentAppViewController.shrinkView()
        }
    }
    
    // MARK: - SwitchMethodDidChangeObserver
    
    func switchMethodDidChange(notification: Notification) {
        guard let method = notification.userInfo?["method"] as? SwitchMethod,
            method != currentAppViewController.currentSwitchMethod else { return }
        switch method {
        case .key:
            currentAppViewController.shrinkView()
        case .window, .hybrid:
            currentAppViewController.expandView()
        }
    }
    
    // MARK: - TriggerSectionVisibilityDidChangeObserver
    
    @objc func triggerSectionVisibilityDidChange(notification: Notification) {
        guard let visible = notification.userInfo?["visible"] as? Bool else { return }
        if visible {
            self.showTriggerSection()
        } else {
            self.hideTriggerSection()
        }
    }
    
    // MARK: - Private functions
    
    private func showTriggerSection() {
        guard let switchMethodItem = self.menu.item(at: 0), let separatorItem = self.menu.item(at: 1) else { return }
        switchMethodItem.view = self.switchMethodViewController.view
        switchMethodItem.isHidden = false
        separatorItem.isHidden = false
    }
    
    private func hideTriggerSection() {
        guard let switchMethodItem = self.menu.item(at: 0), let separatorItem = self.menu.item(at: 1) else { return }
        switchMethodItem.view = nil
        switchMethodItem.isHidden = true
        separatorItem.isHidden = true
    }
}
