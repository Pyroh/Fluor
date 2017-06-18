//
//  MenuItemsController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 16/02/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class MenuItemsController: NSObject, SwitchMethodDidChangeHandler {
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var switchMethodViewController: SwitchMethodViewController!
    @IBOutlet weak var defaultModeViewController: DefaultModeViewController!
    @IBOutlet weak var currentAppViewController: CurrentAppViewController!
    
    override init() {
        super.init()
        startObservingSwitchMethodDidChange()
    }
    
    deinit {
        stopObservingSwitchMethodDidChange()
    }
    
    func setup() {
        let switchingPlaceHolder = menu.item(withTitle: "Switching")
        let statePlaceHolder = menu.item(withTitle: "State")
        let currentPlaceHolder = menu.item(withTitle: "Current")
        switchingPlaceHolder?.view = switchMethodViewController.view
        statePlaceHolder?.view = defaultModeViewController.view
        currentPlaceHolder?.view = currentAppViewController.view
        if case SwitchMethod.fnKey = BehaviorManager.default.switchMethod {
            currentAppViewController.shrinkView()
        }
    }
    
    func switchMethodDidChange(notification: Notification) {
        guard let method = notification.userInfo?["method"] as? SwitchMethod,
            method != currentAppViewController.currentSwitchMethod else { return }
        switch method {
        case .fnKey:
            currentAppViewController.shrinkView()
        case .windowSwitch:
            currentAppViewController.expandView()
        }
    }
}
