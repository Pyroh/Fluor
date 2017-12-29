//
//  TableViewManager.swift
//  Fluor
//
//  Created by Pierre TACCHI on 09/12/2017.
//  Copyright © 2017 Pyrolyse. All rights reserved.
//

import Cocoa

class TableViewContentOrchestrator<ItemType: Hashable>: NSObject, NSTableViewDataSource {
    @objc weak dynamic var tableView: NSTableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    @objc weak dynamic var arrayController: NSArrayController! {
        willSet {
            guard newValue.arrangedObjects is [ItemType] else { fatalError() }
            arrayController.removeObserver(self, forKeyPath: "arrangedObjects")
        }
        didSet {
            self.configureController()
        }
    }
    
    var tableInsertAnimation: NSTableView.AnimationOptions
    var tableRemoveAnimation: NSTableView.AnimationOptions
    
    private var arrangedObjects: [ItemType]? { return arrayController.arrangedObjects as? [ItemType] }
    
    private var hashValues: [Int] = []
    private var animated: Bool = true
    
    private var actualInsertAnimation: NSTableView.AnimationOptions { return animated ? tableInsertAnimation : [] }
    private var actualRemoveAnimation: NSTableView.AnimationOptions { return animated ? tableRemoveAnimation : [] }
    
    init(tableView: NSTableView, arrayController: NSArrayController) {
        self.tableView = tableView
        self.arrayController = arrayController
        self.tableInsertAnimation = [.effectFade]
        self.tableRemoveAnimation = [.effectFade]
        super.init()
        tableView.dataSource = self
        self.configureController()
    }
    
    private func configureController() {
        arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: [], context: nil)
        self.hashValues = self.computeHashes(arrayController.arrangedObjects as! [ItemType])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard arrayController.isEqual(object), keyPath == "arrangedObjects", let newShadowObjects = self.arrangedObjects else { return }
        let newHashValues = self.computeHashes(newShadowObjects)
        let oldItemSet = Set(hashValues)
        let newItemSet = Set(newHashValues)
        let toKeep = newItemSet.intersection(oldItemSet)
        let toRemove = IndexSet(toKeep.symmetricDifference(oldItemSet).flatMap({ self.hashValues.index(of: $0) }))
        let toAdd = IndexSet(toKeep.symmetricDifference(newItemSet).flatMap({ newHashValues.index(of: $0) }))
        
        tableView.beginUpdates()
        self.removeRows(at: toRemove)
        self.insertRows(at: toAdd)
        tableView.endUpdates()
        
        self.hashValues = newHashValues
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
    
    private func insertRows(at indexSet: IndexSet) {
        tableView.insertRows(at: indexSet, withAnimation: self.actualInsertAnimation)
    }
    
    private func removeRows(at indexSet: IndexSet) {
        tableView.removeRows(at: indexSet, withAnimation: self.actualRemoveAnimation)
    }
    
    private func computeHashes(_ array: [ItemType]) -> [Int] {
        return arrangedObjects?.map({$0.hashValue}) ?? []
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrangedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return arrangedObjects?[row]
    }
}
