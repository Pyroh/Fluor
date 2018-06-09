//
//  NSAnimationContextExtension.swift
//  Palette
//
//  Created by Pierre TACCHI on 04/04/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

typealias Anim = NSAnimationContext

public extension NSAnimationContext {
    class func runWith(duration: TimeInterval, changes: (NSAnimationContext) -> (), completionHandler: (() -> ())? = nil) {
        runAnimationGroup({ (ctx) in
            ctx.duration = duration
            changes(ctx)
        }, completionHandler: completionHandler)
    }
    
    class func runUnanimated(changes: () -> ()) {
        runAnimationGroup({ (ctx) in
            ctx.duration = 0.0
            changes()
        }, completionHandler: nil)
    }
}
