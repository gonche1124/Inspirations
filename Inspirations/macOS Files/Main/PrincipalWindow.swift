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
    @IBOutlet weak var segmentedButtons: NSSegmentedControl!
    @IBOutlet weak var infoMessage:NSTextField!
    
    
    //Vars
    var selectedQuotesIDS:[String]?{
        didSet{
            shareButton.isEnabled=true
        }
    }
    
    //MARK: - Lifecycle:
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
        ValueTransformer.setValueTransformer(TooltipCoreData(), forName: NSValueTransformerName(rawValue: "TooltipCoreData"))

        //Register for table updates.
        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(selectedRowsOfDisplayedTableChanged(_:)), name: .rightSelectedRowsChaged, object: nil)
        noti.addObserver(self, selector: #selector(updateText(_:)), name: .updateDisplayText, object: nil)
    }
    
    //Called before preparing for a specific segue.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let addQ = segue.destinationController as? AddQuoteController{
            addQ.viewType = .adding
        }
    }
    
    //MARK: - Export
    /// Exports all the quotes in the database.
    @IBAction func exportAll(_ sender:Any){
        //Create panel to ask user
        if let newFile = self.createSaveDialog(withTitle: "All Quotes -") {
            do {
                let newMOC = (NSApp.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                let coreDataArray = try Quote.objects(in: newMOC)
                try write(data: coreDataArray, toFile: newFile)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Export the selected quotes from the table currently displayed.
    @IBAction func exportSelected (_ sender:Any){
        if let newFile = self.createSaveDialog(withTitle: "Selected Quotes -") {
            do {
                let newMOC = (NSApp.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                let coreDataArray = newMOC.getObjectsWithIDS(asStrings: self.selectedQuotesIDS!) as? [Quote]
                try write(data: coreDataArray, toFile: newFile)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Creates and displays the save panel, returning the URL if the user chooses yes.
    public func createSaveDialog(withTitle: String)->URL?{
        let savePanel = NSSavePanel.init()
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        savePanel.nameFieldStringValue = "\(withTitle) \(timestamp).json"
        if savePanel.runModal() == .OK {
            return savePanel.url
        }
        return nil
    }
    
    /// Write Data to JSON
    public func write<T: Encodable>(data:T, toFile:URL) throws{
        let encoder = JSONEncoder.init()
        encoder.outputFormatting = .prettyPrinted
        let jsonArray = try encoder.encode(data.self)
        try jsonArray.write(to: toFile)
    }
    
    //MARK: - Notifications
    
    /// Notificatoin when the text needs to be updated.
    @objc func updateText(_ notification:Notification){
        if let newText = notification.object as? String{
            infoMessage.stringValue = newText
        }
    }
    
    
    //Selected rows changed
    @objc func selectedRowsOfDisplayedTableChanged(_ notification:Notification){
        if let selQuotes = notification.object as? [String] {
            selectedQuotesIDS=selQuotes
        }
    }
    
    //Actions
//    @IBAction func segmentedAction(_ sender: NSSegmentedControl) {        
//        NotificationCenter.default.post(Notification(name: .selectedViewChanged, object:sender))
//        
//        (NSApp.delegate as? AppDelegate)?.exportSelectedmenu.isEnabled = !(sender.indexOfSelectedItem == 2)
//        (NSApp.delegate as? AppDelegate)?.exportSelectedmenu.isHidden = (sender.indexOfSelectedItem == 2)
//    }
    
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
