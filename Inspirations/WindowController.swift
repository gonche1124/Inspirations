//
//  WindowController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 1/15/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func windowWillLoad() {
        super.windowWillLoad()
        
        //register Values transformers.
        ValueTransformer.setValueTransformer(CollectionToCount(), forName: NSValueTransformerName(rawValue:"myCollectionToCount"))
        ValueTransformer.setValueTransformer(BooleanToImage(), forName: NSValueTransformerName(rawValue: "BooleanToImage"))
        ValueTransformer.setValueTransformer(SetToCount(), forName: NSValueTransformerName(rawValue:"SetToCount"))
        ValueTransformer.setValueTransformer(stringToImage(), forName: NSValueTransformerName(rawValue:"stringToImage"))
        ValueTransformer.setValueTransformer(SetToCompoundString(), forName: NSValueTransformerName(rawValue:"SetToCompoundString"))
        ValueTransformer.setValueTransformer(SetToArray(), forName: NSValueTransformerName(rawValue:"SetToArray"))
        
        //create the security containers to store the data.
        //TODO: Check if this is neccesary!
        let fm = FileManager.default
        let appGroupName = "Gonche.Inspirations"//"Z123456789.com.example.app-group"
        let groupContainerURL = fm.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)
        try! fm.createDirectory(at: groupContainerURL!, withIntermediateDirectories: true, attributes: nil)
        
       //Create the application support folder.
        let bundleID = Bundle.main.bundleIdentifier
        let appSupportDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let suppPath = appSupportDir[0].appendingPathComponent(bundleID!)
        try! fm.createDirectory(at: suppPath, withIntermediateDirectories: true, attributes: nil)
        
        
        
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let sharedItems=SharedItems()
        sharedItems.moc = self.moc
        sharedItems.mainQuoteController=self.quoteController

        
        self.contentViewController?.representedObject=sharedItems
        self.window?.delegate=NSApp.delegate as? AppDelegate
    }
    
    //Set up code for a new segue from the window
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let destController = segue.destinationController as? AddQuote else {return}
        destController.representedObject = self.contentViewController?.representedObject
    }
    
    //MARK: - Variables
    @objc var moc: NSManagedObjectContext = ((NSApp.delegate as? AppDelegate)?.managedObjectContext)!
    @IBOutlet var quoteController: NSArrayController!
    
    //MARK: - Actions
    //TODO: improve.
    @IBAction func changeQuotes(_ sender: NSSegmentedControl) {
        print("changeOfQuotes with: \(sender.indexOfSelectedItem)")
        
        if let splitController=self.contentViewController as? NSSplitViewController{
            splitController.splitViewItems[1].isCollapsed=true
            splitController.splitViewItems[2].isCollapsed=true
            splitController.splitViewItems[3].isCollapsed=true
            splitController.splitViewItems[sender.indexOfSelectedItem+1].isCollapsed=false

            print("It is a split controller with: \(sender)")
        }
        
    }
    
}
