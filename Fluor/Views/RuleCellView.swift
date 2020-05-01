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
            switch self.backgroundStyle {
            case .light:
                self.textField?.textColor = .textColor
            default:
                self.textField?.textColor = .selectedMenuItemTextColor
            }
        }
    }
    
    @IBAction func action(_ sender: Any?) {
        guard let item = objectValue as? Item else {
            return AppErrorManager.showError(withReason: "Can't set behavior")
        }
        
        BehaviorManager.default.propagate(behavior: item.behavior, forApp: item.id, at: item.url, from: item.notificationSource)
    }
}
