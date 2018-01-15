//
//  WindowController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 1/15/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        let sharedItems=SharedItems()
        sharedItems.mainQuoteController=self.quoteController
        self.contentViewController?.representedObject=sharedItems
        
    }
    
    //MARK: - Variables
    @objc var moc: NSManagedObjectContext = ((NSApp.delegate as? AppDelegate)?.managedObjectContext)!
    @IBOutlet var quoteController: NSArrayController!
    
}
