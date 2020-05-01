//
//  AppExterminator.swift
//  Fluor
//
//  Created by Pierre TACCHI on 10/01/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved.
//

import Cocoa

enum AppErrorManager {
    static func showError(withReason reason: @autoclosure () -> String, andMessage msg: String? = nil) {
        let info = reason()
        let message = msg ?? "Sorry, an unexpected error occured."
        let alert = NSAlert()
        
        alert.alertStyle = .warning
        alert.informativeText = info
        alert.messageText = message
        alert.runModal()
    }
    
    static func terminateApp(withReason reason: @autoclosure () -> String, andMessage msg: String? = nil) -> Never {
        let info = reason()
        let message = msg ?? "Sorry, an unexpected error occured."
        let alert = NSAlert()
        
        alert.alertStyle = .critical
        alert.informativeText = info
        alert.messageText = message
        alert.runModal()
        
        NSApp.terminate(self)
        fatalError(info)
    }
}
