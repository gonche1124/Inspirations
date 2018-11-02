//
//  PrincipalWindow.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/27/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class PrincipalWindow: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        //TODO: Finish implementing recent searches.
        //recentSearches=["Toto","Titi","Tata"]
        //mainSearchField.recentSearches=recentSearches
        //mainSearchField.searchMenuTemplate=searchMenu
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func windowWillLoad() {
        super.windowWillLoad()
        
        //Register NSValueTransformers
        ValueTransformer.setValueTransformer(SetToCompoundString(), forName: NSValueTransformerName(rawValue:"SetToCompoundString"))
        ValueTransformer.setValueTransformer(BooleanToImage(), forName: NSValueTransformerName(rawValue: "BooleanToImage"))
    }
    
    //Actions
    @IBAction func segmentedAction(_ sender: NSSegmentedControl) {        
        NotificationCenter.default.post(Notification(name: .selectedViewChanged, object:sender))
        
    }
    
    //Outlets

    @IBOutlet weak var mainSearchField: NSSearchField!
    
    
    //Variables
    var recentSearches = [String]()
//    lazy var searchMenu :NSMenu = {
//        let menu = NSMenu(title: "Recents")
//        let i1 = menu.addItem(withTitle: "Recents Search", action: nil, keyEquivalent: "")
//        i1.tag = Int(NSSearchField.recentsTitleMenuItemTag)
//        let i2 = menu.addItem(withTitle: "Item", action: nil, keyEquivalent: "")
//        i2.tag = Int(NSSearchField.recentsMenuItemTag)
//        let i3 = menu.addItem(withTitle: "Clear", action: nil, keyEquivalent: "")
//        i3.tag = Int(NSSearchField.clearRecentsMenuItemTag)
//        let i4 = menu.addItem(withTitle: "No Recent Search", action: nil, keyEquivalent: "")
//        i4.tag = Int(NSSearchField.noRecentsMenuItemTag)
//
//        return menu
//    }()
   
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let addQ = segue.destinationController as? AddQuoteController{
            addQ.isInfoWindow=false
            //addQ.selectionController?.add(nil)
        }
        
    }
    
}



extension PrincipalWindow:NSWindowDelegate{
    
    //TODO: Think of seomthing useful for this notification.
//    func windowDidResize(_ notification: Notification) {
//        print("Rezising to: \((notification.object as? NSWindow)?.frame.size.width)")
//    }
    
    
    
}
