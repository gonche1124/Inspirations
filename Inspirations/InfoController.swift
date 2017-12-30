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
       // _=self.view.subviews.filter({$0.tag==2}).map({($0 as! NSTextField).isBordered=false})
    }
    
   
    
    @IBAction func makeEditable(_ sender: NSButton) {
        //Change button title and variable.
        self.areItemsEditable = !self.areItemsEditable
        editButton.title = (areItemsEditable) ? "Save": "Edit"
        
        //Change interface to make items editable.
        _=self.view.subviews.filter({$0.tag == 2}).map({($0 as! NSTextField).drawsBackground=areItemsEditable})
        
    }
    
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet var quotesController: NSArrayController!
    @IBOutlet var playlistController: NSArrayController!
    
    @objc dynamic lazy var areItemsEditable: Bool = false
    //@objc dynamic lazy var moc = (NSApp.delegate as! AppDelegate).managedObjectContext
    
    //Refrence to a specific View controller
    @objc dynamic lazy var currentVC: NSArrayController? = {
        let childC=NSApp.mainWindow?.contentViewController?.childViewControllers
        guard let tabC=childC?.first(where: {$0.className=="NSTabViewController"}) as? NSTabViewController else {return nil}
        guard let ccB=tabC.childViewControllers[0] as? CocoaBindingsTable else {return nil}
        return ccB.quotesArrayController
    }()

    
    
    
}

//Token Field Delegate
extension InfoController: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return (playlistController.arrangedObjects as! [Playlist]).map({$0.pName!})
    }
}
