//
//  RuleCellView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 09/06/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class RuleCellView: NSTableCellView {
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            switch backgroundStyle {
            case .light:
                textField?.textColor = NSColor.textColor
            default:
                textField?.textColor = NSColor.selectedMenuItemTextColor
            }
        }
    }
    
    @IBAction func changeBehavior(sender: NSSegmentedControl) {
        guard let objectValue = self.objectValue as? RuleItem else { return }
        objectValue.postChangeNotification()
    }
}
