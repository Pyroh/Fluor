//
//  Release.swift
//  Fluor
//
//  Created by Pierre TACCHI on 20/02/2019.
//  Copyright © 2019 Pyrolyse. All rights reserved.
//

import Foundation

@objcMembers
class Release: NSObject, Decodable {
    dynamic let tag: String
    dynamic let url: URL
    dynamic var displayName: String {
        return "version \(tag)"
    }
}
