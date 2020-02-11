//
//  ResultExtension.swift
//  Fluor
//
//  Created by Pierre TACCHI on 06/02/2020.
//  Copyright © 2020 Pyrolyse. All rights reserved.
//

extension Result {
    func getOrFailWith(_ block: (Failure) -> Never) -> Success {
        switch self {
        case .success(let success):
            return success
        case .failure(let failure):
            block(failure)
        }
    }
}

