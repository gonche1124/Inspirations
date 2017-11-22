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
        (self.parent as? ViewController)?.searchQuote2.delegate = self
    }
    
    //Variables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //IBOutlets
    @IBOutlet var quotesArray: NSArrayController!
    @IBOutlet weak var quotesTable: NSTableView!
    
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


extension QuoteController: NSSearchFieldDelegate {
    
    //Gets called everytime the text changes.
    override func controlTextDidChange(_ obj: Notification) {
        let searchString = (obj.object as? NSSearchField)!.stringValue
        if searchString != "" {
            self.quotesArray.filterPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@",searchString)
            self.quotesTable.reloadData()
            (self.parent as? ViewController)?.updateInfoLabel(parameter: (self.quotesArray.arrangedObjects as! NSArray).count)

        }
    }
    
    //Gets called when
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.quotesArray.filterPredicate=nil
        self.quotesTable.reloadData()
        (self.parent as? ViewController)?.updateInfoLabel(parameter: "All")
    }
    
}
