//
//  SwitchMethodSelectionViewController.swift
//  Fluor
//
//  Created by Pierre TACCHI on 26/02/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved.
//

import Cocoa

protocol WelcomeTabViewChildren: NSViewController {
    var welcomeTabViewController: WelcomeTabViewController? { get }
}

extension WelcomeTabViewChildren {
    var welcomeTabViewController: WelcomeTabViewController? {
        self.presentingViewController as? WelcomeTabViewController
    }
}

class SwitchMethodSelectionViewController: NSViewController, WelcomeTabViewChildren {
    @IBOutlet weak var activeAppSelectableView: SelectableView!
    @IBOutlet weak var fnKeySelectableView: SelectableView!
    
    deinit {
        self.resignAsObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyAsObserver()
    }
    
    private func applyAsObserver() {
        self.activeAppSelectableView.addObserver(self, forKeyPath: "isSelected", options: [.new], context: nil)
        self.fnKeySelectableView.addObserver(self, forKeyPath: "isSelected", options: [.new], context: nil)
    }
    
    private func resignAsObserver() {
        self.activeAppSelectableView.removeObserver(self, forKeyPath: "isSelected")
        self.fnKeySelectableView.removeObserver(self, forKeyPath: "isSelected")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "isSelected":
            if object as AnyObject === self.activeAppSelectableView, change?[.newKey] as? Bool == true {
                self.activeAppHasBeenSelected()
            }
            if object as AnyObject === self.fnKeySelectableView, change?[.newKey] as? Bool == true {
                self.fnKeyHasBeenSelected()
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func activeAppHasBeenSelected() {
        self.fnKeySelectableView.isSelected = false
    }
    
    private func fnKeyHasBeenSelected() {
        self.activeAppSelectableView.isSelected = false
    }
}
