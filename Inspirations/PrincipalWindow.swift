//
//  PrincipalWindow.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/27/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class PrincipalWindow: NSWindowController {
    
    //Outlets
    @IBOutlet var shareButton:NSButton!
    @IBOutlet weak var mainSearchField: NSSearchField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentViewController?.representedObject=(NSApp.delegate as? AppDelegate)?.managedObjectContext
        
        //Fixes bug:
       shareButton.sendAction(on: .leftMouseDown)
        
    }
    
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
        ValueTransformer.setValueTransformer(EntityToToken(), forName: NSValueTransformerName(rawValue: "EntityToToken"))
    }
    
    //Actions
    @IBAction func segmentedAction(_ sender: NSSegmentedControl) {        
        NotificationCenter.default.post(Notification(name: .selectedViewChanged, object:sender))
        
    }
    
    
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
    
    //Sharing sheet
    @IBAction func shareSheet(_ sender:NSButton){
        let textToDelete="sdjbf sjdb sbd m"
        //TODO: How to pass selectedQuotes
        let sharingPicker = NSSharingServicePicker(items: [textToDelete])
        
        //Present
        sharingPicker.delegate=self
        sharingPicker.show(relativeTo: NSZeroRect, of: sender, preferredEdge: .minY)
    }
}

//MARK: - NSSharingServicePickerDeleate
extension PrincipalWindow:NSSharingServicePickerDelegate{
   
    //Cusotmizaion before appearance.
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        guard let image = NSImage(named: NSImage.Name("copy")) else {
            return proposedServices
        }
        
        var share = proposedServices
        let customService = NSSharingService(title: "Copy Text", image: image, alternateImage: image, handler: {
            if let text = items.first as? String {
                print("Clipboard\(text)")
                //self.setClipboard(text: text)
            }
        })
        share.insert(customService, at: 0)
        
        return share
    }
}



extension PrincipalWindow:NSWindowDelegate{
    
}
