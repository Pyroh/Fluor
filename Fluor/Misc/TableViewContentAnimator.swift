//
//  TableViewContentAnimator.swift
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

final class TableViewContentAnimator<ItemType: AnyObject>: NSObject, NSTableViewDataSource {
    @objc weak dynamic var tableView: NSTableView!
    @objc weak dynamic var arrayController: NSArrayController!
    
    var tableInsertAnimation: NSTableView.AnimationOptions
    var tableRemoveAnimation: NSTableView.AnimationOptions
    
    private var arrangedObjects: [ItemType]? { return arrayController.arrangedObjects as? [ItemType] }
    
    private var shadowObjects: [ItemType] = []
    private var animated: Bool = true
    
    private var actualInsertAnimation: NSTableView.AnimationOptions { return animated ? tableInsertAnimation : [] }
    private var actualRemoveAnimation: NSTableView.AnimationOptions { return animated ? tableRemoveAnimation : [] }
    
    init(tableView: NSTableView, arrayController: NSArrayController) {
        self.tableView = tableView
        self.arrayController = arrayController
        self.tableInsertAnimation = [.effectFade]
        self.tableRemoveAnimation = [.effectFade]
        super.init()
        self.tableView.dataSource = self
        self.configureController()
    }
    
    deinit {
        arrayController.removeObserver(self, forKeyPath: "arrangedObjects")
    }
    
    private func configureController() {
        arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: [], context: nil)
        self.shadowObjects = arrayController.arrangedObjects as! [ItemType]
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard arrayController.isEqual(object), keyPath == "arrangedObjects", let newShadowObjects = self.arrangedObjects else { return }
        let itemsToKeep = self.intersection(between: self.shadowObjects, and: newShadowObjects)
        let itemsToRemove = self.substract(itemsToKeep, from: self.shadowObjects)
        let itemsToAdd = self.substract(itemsToKeep, from: newShadowObjects)
        let removeSet = IndexSet(itemsToRemove.compactMap { item in
            self.shadowObjects.firstIndex(where: { item === $0 })
        })
        let addSet = IndexSet(itemsToAdd.compactMap { item in
            newShadowObjects.firstIndex(where: { item === $0 })
        })
        
        self.shadowObjects = newShadowObjects
        
        tableView.beginUpdates()
        self.removeRows(at: removeSet)
        self.insertRows(at: addSet)
        tableView.endUpdates()
    }
    
    func performUnanimated(_ block: () -> ()) {
        self.animated = false
        block()
        self.animated = true
    }
    
    func disableAnimations() {
        self.animated = false
    }
    
    func enabledAnimations() {
        self.animated = true
    }
    
    // MARK: - Private functions
    
    private func insertRows(at indexSet: IndexSet) {
        tableView.insertRows(at: indexSet, withAnimation: self.actualInsertAnimation)
    }
    
    private func removeRows(at indexSet: IndexSet) {
        tableView.removeRows(at: indexSet, withAnimation: self.actualRemoveAnimation)
    }
    
    private func intersection(between lhs: [ItemType], and rhs: [ItemType]) -> [ItemType] {
        return rhs.compactMap { item in
            lhs.contains(where: { item === $0 }) ? item : nil
        }
    }
    
    private func substract(_ sub: [ItemType], from source: [ItemType]) -> [ItemType] {
        var result = source
        sub.forEach { item in
            guard let index = result.firstIndex(where: { item === $0 }) else { return }
            result.remove(at: index)
        }
        return result
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrangedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return arrangedObjects?[row]
    }
}
