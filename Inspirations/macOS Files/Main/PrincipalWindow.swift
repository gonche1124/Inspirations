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
    
    //Vars
    var selectedQuotesIDS:[String]?{
        didSet{
            shareButton.isEnabled=true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.contentViewController?.representedObject=(NSApp.delegate as? AppDelegate)?.managedObjectContext
        
        //Fixes bug:
       shareButton.sendAction(on: .leftMouseDown)
        
    }
    
    override func windowWillLoad() {
        super.windowWillLoad()
        
        //Register NSValueTransformers
        ValueTransformer.setValueTransformer(SetToCompoundString(), forName: NSValueTransformerName(rawValue:"SetToCompoundString"))
        ValueTransformer.setValueTransformer(BooleanToImage(), forName: NSValueTransformerName(rawValue: "BooleanToImage"))
        ValueTransformer.setValueTransformer(EntityToToken(), forName: NSValueTransformerName(rawValue: "EntityToToken"))
        ValueTransformer.setValueTransformer(TooltipCoreData(), forName: NSValueTransformerName(rawValue: "TooltipCoreData"))
        
    
    
        //Register for table updates.
        NotificationCenter.default.addObserver(self, selector: #selector(selectedRowsOfDisplayedTableChanged(_:)), name: .selectedRowsChaged, object: nil)
        
        
    }
    
    //Selected rows changed
    @objc func selectedRowsOfDisplayedTableChanged(_ notification:Notification){
        if let selQuotes = notification.object as? [String] {
            selectedQuotesIDS=selQuotes
        }
    }
    
    //Actions
    @IBAction func segmentedAction(_ sender: NSSegmentedControl) {        
        NotificationCenter.default.post(Notification(name: .selectedViewChanged, object:sender))
        
    }
   
    //Called before preparing for a specific segue.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let addQ = segue.destinationController as? AddQuoteController{
            addQ.isInfoWindow=false
        }
    }
    
    @IBAction func importFromMenu(_ sender:Any){
        self.performSegue(withIdentifier: "importSheet", sender: self)
    }
    
    //Sharing sheet
    @IBAction func shareSheet(_ sender:NSButton){
        let moc = (NSApp.delegate as? AppDelegate)?.managedObjectContext
        if let quoteArray=moc?.getObjectsWithIDS(asStrings: selectedQuotesIDS!) as? [Quote]{
            
            let sharingPicker = NSSharingServicePicker(items: quoteArray.map({$0.textForSharing()}))
            
            //Present used in async to avoid warning
            sharingPicker.delegate=self
            sharingPicker.show(relativeTo: NSZeroRect, of: sender, preferredEdge: .minY)
        }
    }
}

//MARK: - NSSharingServicePickerDeleate
extension PrincipalWindow:NSSharingServicePickerDelegate{
   
    //Customization before appearance.
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        guard let image = NSImage(named: "Copy") else {
            return proposedServices
        }
        
        var share = proposedServices
        let customService = NSSharingService(title: "Copy Text", image: image, alternateImage: image, handler: {
            if let text = items.first as? String {
                print("Clipboard: \(text)")
                //self.setClipboard(text: text)
            }
        })
        share.insert(customService, at: 0)
        return share
    }
}


//MARK: - NSWidnowDelegate.
extension PrincipalWindow:NSWindowDelegate{
    
    //Called to reposition the window on top of toolbar and not below.
    func window(_ window: NSWindow, willPositionSheet sheet: NSWindow, using rect: NSRect) -> NSRect {
        guard let contentView = window.contentView  else { return rect}
        let toolBarHeight=NSHeight(window.frame) - NSHeight(contentView.frame)
        var myRect=rect
        myRect.origin.y=myRect.origin.y+toolBarHeight
        return myRect
    }
}
