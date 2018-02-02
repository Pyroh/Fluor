//
//  RuleValueTransformer.swift
//  Fluor
//
//  Created by Pierre TACCHI on 09/06/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class RuleValueTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let inputValue = value as? NSNumber else { return nil }
        return NSNumber(value: inputValue.intValue - 1)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let inputValue = value as? NSNumber else { return nil }
        return NSNumber(value: inputValue.intValue + 1)
    }
}
