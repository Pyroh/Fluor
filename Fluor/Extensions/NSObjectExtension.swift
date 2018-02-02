//
//  NSObjectExtension.swift
//  Fluor
//
//  Created by Pierre TACCHI on 07/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

fileprivate func nsnullToOptionnal(value: Any?) -> Any? {
    return value is NSNull ? nil : value
}


public extension NSObject {
    public func propagateBoundValue(value: Any?, forBinding bindingName: NSBindingName) {
        guard let info = self.infoForBinding(bindingName) else { return }
        guard let boundObject = nsnullToOptionnal(value: info[.observedObject]) as? NSObject,
            let boundKeyPath = nsnullToOptionnal(value: info[.observedKeyPath]) as? String
            else {
                fatalError("No binding info found for key \(bindingName)")
        }
        
        if let opt = info[.options] as? [NSBindingOption: AnyObject], let transformer = nsnullToOptionnal(value: opt[.valueTransformer]) as? ValueTransformer ??
            (opt[.valueTransformerName] as? String).flatMap({
                ValueTransformer(forName: NSValueTransformerName(rawValue: $0))
            }), NSClassFromString(transformer.className)!.allowsReverseTransformation() {
            boundObject.setValue(transformer.reverseTransformedValue(value), forKeyPath: boundKeyPath)
        } else {
            boundObject.setValue(value, forKeyPath: boundKeyPath)
        }
    }
}
