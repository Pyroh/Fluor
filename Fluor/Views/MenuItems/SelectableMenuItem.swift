//
//  SelectableMenuItem.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/01/2018.
//  Copyright © 2018 Pyrolyse. All rights reserved.
//

import Cocoa

class SelectableItemViewController: NSViewController {
    private enum Appearance {
        case aqua
        case light
        case dark
        
        var color: NSColor {
            switch self {
            case .light:
                return .black
            default:
                return .white
            }
        }
        
        var highlightForegroundColor: NSColor {
            return .white
        }
        
        var highlightBackgroundColor: NSColor {
            switch self {
            case .light:
                return NSColor(calibratedRed: 0.2182, green: 0.5095, blue: 0.9739, alpha: 1.0)
            case .dark:
                return NSColor(calibratedRed: 0.2016, green: 0.4915, blue: 0.9738, alpha: 1.0)
            default:
                return .keyboardFocusIndicatorColor
            }
        }
        
        init(from name: NSAppearance.Name?) {
            if let name = name {
                switch name {
                case .vibrantLight :
                    self = .light
                case .vibrantDark:
                    self = .dark
                default:
                    self = .aqua
                }
            } else {
                self = .aqua
            }
        }
    }
    
    static let nibName = NSNib.Name(rawValue: "SelectableMenuItemView")
    
    @IBOutlet weak var imageView: TemplateImageView!
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var label: NSTextField!
    
    private var trackingArea: NSTrackingArea?
    private var itemAppearance: Appearance {
        didSet {
            label.textColor = itemAppearance.color
            imageView.controlTint = itemAppearance.color
        }
    }
    
    fileprivate unowned let menuItem: SelectableMenuItem
    
    fileprivate var itemState: NSControl.StateValue {
        didSet {
            switch itemState {
            case .off:
                imageView.image = #imageLiteral(resourceName: "CheckDisabled")
            case .on:
                imageView.image = #imageLiteral(resourceName: "CheckEnabled")
            case .mixed:
                imageView.image = #imageLiteral(resourceName: "CheckMixed")
            default:
                imageView.image = nil
            }
        }
    }
    
    fileprivate var itemTitle: String {
        didSet {
            label.stringValue = itemTitle
        }
    }
    
    fileprivate var isItemEnabled: Bool {
        didSet {
            imageView.isEnabled = isItemEnabled
            label.isEnabled = isItemEnabled
        }
    }
    
    fileprivate var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                box.fillColor = itemAppearance.highlightBackgroundColor
                label.textColor = itemAppearance.highlightForegroundColor
                imageView.controlTint = itemAppearance.highlightForegroundColor
            } else {
                box.fillColor = .clear
                label.textColor = itemAppearance.color
                imageView.controlTint = itemAppearance.color
            }
        }
    }
    
    init(menuItem item: SelectableMenuItem) {
        self.menuItem = item
        self.itemState = .off
        self.itemTitle = ""
        self.isItemEnabled = true
        self.itemAppearance = .aqua
        self.isHighlighted = false
        
        super.init(nibName: SelectableItemViewController.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        self.view.nextResponder = self
    }
    
    override func viewDidLayout() {
        self.updateTrackingArea()
        self.itemAppearance = Appearance(from: view.nameOfVibrantAncestor)
    }
    
    override func mouseUp(with event: NSEvent) {
        menuItem.clicked()
        menuItem.menu?.cancelTracking()
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.isHighlighted = true
    }
    
    override func mouseExited(with event: NSEvent) {
        self.isHighlighted = false
    }
    
    private func updateTrackingArea() {
        if let ta = trackingArea {
            view.removeTrackingArea(ta)
        }
        self.trackingArea = NSTrackingArea(rect: view.frame, options: [.mouseEnteredAndExited, .enabledDuringMouseDrag, .activeAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea!)
    }
}

class SelectableMenuItem: NSMenuItem {
    private var viewController: SelectableItemViewController?
    
    override var title: String {
        didSet {
            viewController?.itemTitle = title
        }
    }
    override var state: NSControl.StateValue {
        didSet {
            viewController?.itemState = state
        }
    }
    override var toolTip: String? {
        didSet {
            viewController?.view.toolTip = toolTip
        }
    }
    override var isEnabled: Bool {
        didSet {
            viewController?.isItemEnabled = isEnabled
        }
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.setupViewController()
    }
    
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
        self.setupViewController()
    }
    
    private func setupViewController() {
        if self.viewController == nil { self.viewController = SelectableItemViewController(menuItem: self) }
        if self.view == nil {
            self.view = viewController?.view
        }
        viewController?.itemState = self.state
        viewController?.itemTitle = self.title
        viewController?.view.toolTip = self.toolTip
        viewController?.isItemEnabled = self.isEnabled
    }
    
    fileprivate func clicked() {
        if self.infoForBinding(.value) != nil {
            let nextState = self.nextStateValue()
            self.state = nextState
            self.propagateBoundValue(value: nextState, forBinding: .value)
        }
        if let action = self.action {
            _ = target?.perform(action, with: self)
        }
        
        viewController?.isHighlighted = false
//        menu?.cancelTracking()
    }
    
    private func nextStateValue() -> NSControl.StateValue {
        switch self.state {
        case .on:
            return .off
        case .mixed, .off:
            return .on
        default:
            return .mixed
        }
    }
}
