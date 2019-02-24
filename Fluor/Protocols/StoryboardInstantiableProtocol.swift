//
//  InstantInstanceViewControllerProtocol.swift
//  Fluor
//
//  Created by Pierre TACCHI on 16/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

protocol StoryboardInstantiable: NSObjectProtocol {
    static var storyboardName: NSStoryboard.Name { get }
    static var sceneIdentifier: NSStoryboard.SceneIdentifier? { get }
    static var bundle: Bundle? { get }
    
    static func instantiate() -> Self
}

extension StoryboardInstantiable {
    static var sceneIdentifier: NSStoryboard.SceneIdentifier? { return nil }
    static var bundle: Bundle? { return nil }
    
    static func instantiate() -> Self {
        if let id = sceneIdentifier {
            return NSStoryboard(name: storyboardName, bundle: bundle).instantiateController(withIdentifier: id) as! Self
        } else {
            return NSStoryboard(name: storyboardName, bundle: bundle).instantiateInitialController() as! Self
        }
    }
}
