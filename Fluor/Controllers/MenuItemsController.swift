//
//  MenuItemsController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 16/02/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class MenuItemsController: NSObject, SwitchMethodDidChangeObserver, TriggerSectionVisibilityDidChangeObserver {
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var switchMethodViewController: SwitchMethodViewController!
    @IBOutlet weak var defaultModeViewController: DefaultModeViewController!
    @IBOutlet weak var currentAppViewController: CurrentAppViewController!
    
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
        if case SwitchMethod.key = BehaviorManager.default.switchMethod {
            currentAppViewController.shrinkView()
        }
    }
    
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
    
    @objc func triggerSectionVisibilityDidChange(notification: Notification) {
        guard let visible = notification.userInfo?["visible"] as? Bool else { return }
        if visible {
            self.showTriggerSection()
        } else {
            self.hideTriggerSection()
        }
    }
}
