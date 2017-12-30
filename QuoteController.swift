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
        //(self.parent as? ViewController)?.searchQuote2.delegate = self
        
        //Bind the array controller to the nssearchfield
        //Bind the array controller to the nssearchfield
        if let searchField = mainToolbarItems?.first(where: {$0.itemIdentifier.rawValue=="searchToolItem"})?.view as? NSSearchField{
            //Get dictionaries
            let dQuotes = self.searchBindingDictionary(withName: "Quote", andPredicate: "quote CONTAINS[cd] $value")
            let dAuthor = self.searchBindingDictionary(withName: "Author", andPredicate: "fromAuthor.name CONTAINS[cd] $value")
            let dThemes = self.searchBindingDictionary(withName: "Themes", andPredicate: "isAbout.topic CONTAINS[cd] $value")
            let dTags = self.searchBindingDictionary(withName: "Tags", andPredicate: "tags.tag CONTAINS[cd] $value")
            let dAll = self.searchBindingDictionary(withName: "All", andPredicate: "(quote CONTAINS[cd] $value) OR (fromAuthor.name CONTAINS[cd] $value) OR (isAbout.topic CONTAINS[cd] $value) OR (tags.tag CONTAINS[cd] $value)")
            //Set up bindings
            searchField.bind(.predicate, to: quotesArray, withKeyPath: "filterPredicate", options:dAll)
            searchField.bind(NSBindingName("predicate2"), to: quotesArray, withKeyPath: "filterPredicate", options:dAuthor)
            searchField.bind(NSBindingName("predicate3"), to: quotesArray, withKeyPath: "filterPredicate", options:dQuotes)
            searchField.bind(NSBindingName("predicate4"), to: quotesArray, withKeyPath: "filterPredicate", options:dThemes)
            searchField.bind(NSBindingName("predicate5"), to: quotesArray, withKeyPath: "filterPredicate", options:dTags)
        }
    }
    
    
    
    //Variables
    //@objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
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
