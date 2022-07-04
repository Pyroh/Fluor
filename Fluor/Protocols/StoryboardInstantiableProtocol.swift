//
//  StoryboardInstantiableProtocol.swift
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

protocol StoryboardInstantiable: NSObjectProtocol {
    static var storyboardName: NSStoryboard.Name { get }
    static var sceneIdentifier: NSStoryboard.SceneIdentifier? { get }
    static var bundle: Bundle? { get }
    
    static func instantiate() -> Self
}

extension StoryboardInstantiable {
    static var sceneIdentifier: NSStoryboard.SceneIdentifier? { nil }
    static var bundle: Bundle? { nil }
    
    static func instantiate() -> Self {
        if let id = sceneIdentifier {
            return NSStoryboard(name: storyboardName, bundle: bundle).instantiateController(withIdentifier: id) as! Self
        } else {
            guard
                let object = NSStoryboard(name: storyboardName, bundle: bundle).instantiateInitialController() as? Self
            else { fatalError("Unable to instantiate initial controller from the \(storyboardName) storyboard.") }
            return object
        }
    }
}
