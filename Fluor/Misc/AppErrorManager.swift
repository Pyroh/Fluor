//
//  AppExterminator.swift
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

enum AppErrorManager {
    static func showError(withReason reason: @autoclosure () -> String, andMessage msg: String? = nil) {
        let info = reason()
        let message = msg ?? NSLocalizedString("Sorry, an unexpected error occured.", comment: "")
        let alert = NSAlert()
        
        alert.alertStyle = .warning
        alert.informativeText = info
        alert.messageText = message
        alert.runModal()
    }
    
    static func terminateApp(withReason reason: @autoclosure () -> String, andMessage msg: String? = nil) -> Never {
        let info = reason()
        let message = msg ?? NSLocalizedString("Sorry, an unexpected error occured.", comment: "")
        let alert = NSAlert()
        
        alert.alertStyle = .critical
        alert.informativeText = info
        alert.messageText = message
        alert.runModal()
        
        NSApp.terminate(self)
        fatalError(info)
    }
}
