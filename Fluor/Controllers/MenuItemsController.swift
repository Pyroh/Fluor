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
    
    func setupController() {
        let switchingPlaceHolder = menu.item(withTag: 12)
        let statePlaceHolder = menu.item(withTag: 11)
        let currentPlaceHolder = menu.item(withTag: 10)
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
        case .window:
            currentAppViewController.expandView()
        }
    }
}
