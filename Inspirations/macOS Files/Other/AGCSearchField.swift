//
//  File.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 4/7/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Foundation
import Cocoa

class AGCSearchField: NSSearchField {
    
    //Constants
    static let separator = NSMenuItem.separator()
    static let clearAction = NSMenuItem(title: "Clear", action: nil, keyEquivalent: "", tag: NSSearchField.clearRecentsMenuItemTag)
    static let recentsTitle = NSMenuItem(title: "Recent Searches", action: nil, keyEquivalent: "", tag: NSSearchField.recentsTitleMenuItemTag)
    static let recentPlaceholder = NSMenuItem(title: "Search X", action: nil, keyEquivalent: "", tag: NSSearchField.recentsMenuItemTag)
    
    
    //Attributes.
    @IBInspectable var nonEditingWidth: CGFloat = 100
    @IBInspectable var editingWidth: CGFloat = 200
    @IBInspectable var shouldExpandWhenEditing:Bool = false
    @IBInspectable var includeHistoryMenu:Bool = false
    
    
    
    
    var isExpanded:Bool = false
    var widthConstraint:NSLayoutConstraint?
    var expectingCurrentEditor: Bool = false
    
    //INIT
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //setup view.
        
        if self.includeHistoryMenu {
            self.addHistoryMenu()
        }
        
        if shouldExpandWhenEditing {
            self.addWidthConstraints()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.includeHistoryMenu {
            self.addHistoryMenu()
        }
        
        if shouldExpandWhenEditing {
            self.addWidthConstraints()
        }
    }
    
    //Called when it becomes the first responder.
    override func becomeFirstResponder() -> Bool {
        let status = super.becomeFirstResponder()
        if status {
            expectingCurrentEditor = true
        }
        print("SearchFieldBecame first responder")
        if shouldExpandWhenEditing {
             isExpanded = true
            self.widthConstraint?.animator().constant = editingWidth
        }
       
        return status
    }
    
    /// - Note: https://stackoverflow.com/questions/25692122/how-to-detect-when-nstextfield-has-the-focus-or-is-its-content-selected-cocoa
    override func resignFirstResponder() -> Bool {
        let status = super.resignFirstResponder()
        if let _ = self.currentEditor(),  expectingCurrentEditor , status == true, shouldExpandWhenEditing, !isExpanded {
                isExpanded = true
                self.widthConstraint?.animator().constant = editingWidth
        }
        self.expectingCurrentEditor = false
        return status
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        if self.currentEditor() == nil, shouldExpandWhenEditing, isExpanded {
                isExpanded = false
                self.widthConstraint?.animator().constant = nonEditingWidth
        }
    }
    
    // Sets up the Width Constraints used later on to expand and collapse.
    func addWidthConstraints(){
        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(nonEditingWidth))
        width.priority = .defaultHigh
        width.identifier = "currentWidth"
        self.widthConstraint = width
        self.addConstraint(width)
        self.updateConstraints()
    }
    
    /// Sets up the history menu
    func addHistoryMenu(){
        let cellMenu = NSMenu.init(title: "Search menu")
        cellMenu.insertItem(AGCSearchField.clearAction.copy() as! NSMenuItem, at: 0)
        cellMenu.insertItem(AGCSearchField.separator.copy() as! NSMenuItem, at: 1)
        cellMenu.insertItem(AGCSearchField.recentsTitle.copy() as! NSMenuItem, at: 2)
        cellMenu.insertItem(AGCSearchField.recentPlaceholder.copy() as! NSMenuItem, at: 3)
        self.searchMenuTemplate = cellMenu
    }
}
