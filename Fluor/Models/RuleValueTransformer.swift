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
        true
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSNumber.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        (value as? Int).map { NSNumber(value: $0 - 1) }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        (value as? Int).map { NSNumber(value: $0 + 1) }
    }
}
