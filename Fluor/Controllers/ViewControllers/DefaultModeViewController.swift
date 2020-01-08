//
//  StatusView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

@objc protocol DefaultModeViewControllerDelegate: class {
    @objc optional func defaultModeController(_ controller: DefaultModeViewController, willChangeModeTo mode: FKeyMode)
    func defaultModeController(_ controller: DefaultModeViewController, didChangeModeTo mode: FKeyMode)
}

class DefaultModeViewController: NSViewController {
    @IBOutlet weak var delegate: (AnyObject & DefaultModeViewControllerDelegate)?
    
    /// Change the current keyboard state.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func changeMode(_ sender: NSSegmentedControl) {
        guard let state = FKeyMode(rawValue: sender.selectedSegment) else { return }
        delegate?.defaultModeController?(self, willChangeModeTo: state)
        delegate?.defaultModeController(self, didChangeModeTo: state)
    }
}
