//
//  SetExtension.swift
//  Fluor
//
//  Created by Pierre TACCHI on 07/02/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved.
//

import DefaultsWrapper

extension Set: UserDefaultsConvertible where Element: UserDefaultsConvertible {
    public func convertedObject() -> [Element.PropertyListSerializableType] {
        self.map { $0.convertedObject() }
    }
    
    public static func instanciate(from object: [Element.PropertyListSerializableType]) -> Self? {
        Set(object.compactMap(Element.instanciate(from:)))
    }
}

infix operator ?->: TernaryPrecedence

func ?-><T>(lhs: @autoclosure () -> Bool, rhs: @autoclosure () -> T?) -> T? {
    lhs() ? rhs() : nil
}
