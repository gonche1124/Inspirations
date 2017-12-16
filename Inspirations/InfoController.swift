//
//  InfoController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/10/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class InfoController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
   
    
    @IBAction func makeEditable(_ sender: NSButton) {
        //Change button title and variable.
        self.areItemsEditable = !self.areItemsEditable
        editButton.title = (areItemsEditable) ? "Save": "Edit"
        
        //Change interface to make items editable.
        _=self.view.subviews.filter({$0.tag == 2}).map({($0 as! NSTextField).drawsBackground=areItemsEditable})
        
        
    }
    
    @IBOutlet weak var editButton: NSButton!
    
    @objc dynamic lazy var areItemsEditable: Bool = false
    @objc dynamic lazy var moc = (NSApp.delegate as! AppDelegate).managedObjectContext
    
    //Refrence to a specific View controller
    @objc dynamic lazy var currentVC: NSArrayController = (NSApp.mainWindow?.contentViewController as! ViewController).VCPlainTable.quotesArrayController

    
}
