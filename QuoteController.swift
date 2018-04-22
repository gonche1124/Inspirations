//
//  QuoteController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/26/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


//Controller Class
class QuoteController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    
    //IBOutlets
    @IBOutlet var quotesArray: NSArrayController!
    @IBOutlet weak var quotesTable: NSTableView!
    @IBOutlet var authorsController: NSArrayController!
    @IBOutlet var themesController: NSArrayController!
}

// MARK: Extensions
extension QuoteController: NSTableViewDataSource{
    
    //Drag -n- Drop
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        
        let selectedQuotes = (quotesArray.arrangedObjects as! NSArray).objects(at: rowIndexes) as! [Quote]
        let selectedURI = selectedQuotes.map({$0.objectID.uriRepresentation()})
        pboard.setData(NSKeyedArchiver.archivedData(withRootObject:selectedURI), forType: NSPasteboard.PasteboardType.fileContents)
        return true
    }
    
}

