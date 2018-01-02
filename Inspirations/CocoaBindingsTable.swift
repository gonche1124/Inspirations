//
//  CocoaBindingsTable.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/19/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa

class CocoaBindingsTable: NSViewController {
    
    
    //View will Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //Set delegate of searcfiled when view will appear.
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //Bind the array controller to the nssearchfield
        if let searchField = mainToolbarItems?.first(where: {$0.itemIdentifier.rawValue=="searchToolItem"})?.view as? NSSearchField{
            //Get dictionaries
            let dQuotes = self.searchBindingDictionary(withName: "Quote", andPredicate: "quote CONTAINS[cd] $value")
            let dAuthor = self.searchBindingDictionary(withName: "Author", andPredicate: "fromAuthor.name CONTAINS[cd] $value")
            let dThemes = self.searchBindingDictionary(withName: "Themes", andPredicate: "isAbout.topic CONTAINS[cd] $value")
            let dTags = self.searchBindingDictionary(withName: "Tags", andPredicate: "tags.tag CONTAINS[cd] $value")
            let dAll = self.searchBindingDictionary(withName: "All", andPredicate: "(quote CONTAINS[cd] $value) OR (fromAuthor.name CONTAINS[cd] $value) OR (isAbout.topic CONTAINS[cd] $value) OR (tags.tag CONTAINS[cd] $value)")
            //Set up bindings
            searchField.bind(.predicate, to: quotesArrayController, withKeyPath: "filterPredicate", options:dAll)
            searchField.bind(NSBindingName("predicate2"), to: quotesArrayController, withKeyPath: "filterPredicate", options:dAuthor)
            searchField.bind(NSBindingName("predicate3"), to: quotesArrayController, withKeyPath: "filterPredicate", options:dQuotes)
            searchField.bind(NSBindingName("predicate4"), to: quotesArrayController, withKeyPath: "filterPredicate", options:dThemes)
            searchField.bind(NSBindingName("predicate5"), to: quotesArrayController, withKeyPath: "filterPredicate", options:dTags)
            
        }
        
        //Bind Information Label.
      
        if let infoLabel2 = NSApp.mainWindow?.contentView?.viewWithTag(1) as? NSTextField{
            
            infoLabel2.bind(NSBindingName("displayPatternValue1"), to: quotesArrayController, withKeyPath: "selection.@count", options: [NSBindingOption(rawValue: "NSDisplayPattern"):"%{value1}@ of %{value2}@ Selected, %{value3}@ authors, %{value4}@ Topics"])
            infoLabel2.bind(NSBindingName("displayPatternValue2"), to: quotesArrayController, withKeyPath: "arrangedObjects.@count", options: [NSBindingOption(rawValue: "NSDisplayPattern"):"%{value1}@ of %{value2}@ Selected, %{value3}@ authors, %{value4}@ Topics"])
            //infoLabel2.bind(NSBindingName("displayPatternValue3"), to: quotesArrayController, withKeyPath: "selection.@count.fromAuthor", options: [NSBindingOption(rawValue: "NSDisplayPattern"):"%{value1}@ of %{value2}@ Selected, %{value3}@ authors"])
            infoLabel2.bind(NSBindingName("displayPatternValue3"), to: authorsController, withKeyPath: "arrangedObjects.@count", options:[NSBindingOption(rawValue: "NSDisplayPattern"):"%{value1}@ of %{value2}@ Selected, %{value3}@ authors, %{value4}@ Topics"])
            infoLabel2.bind(NSBindingName("displayPatternValue4"), to: themesController, withKeyPath: "arrangedObjects.@count", options:[NSBindingOption(rawValue: "NSDisplayPattern"):"%{value1}@ of %{value2}@ Selected, %{value3}@ authors, %{value4}@ Topics"])
            //infoLabel2.stringValue="test"
            
            
            //infoLabel2.bind(.displayPatternValue, to: quotesArrayController, withKeyPath: "displayValuePattern", options: [])
        }
    }
    
 
    
    //IBOutlets
    @IBOutlet var quotesArrayController: NSArrayController!
    @IBOutlet weak var columnsTable: NSTableView!
    @IBOutlet var authorsController: NSArrayController!
    
    @IBOutlet var themesController: NSArrayController!
    //Get keyboard keystrokes.
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    //Delete record.
    override func deleteBackward(_ sender: Any?) {

        let selectedIndex = columnsTable.selectedRowIndexes
        let confirmationD = NSAlert()
        confirmationD.messageText = "Delete Records"
        confirmationD.informativeText = "Are you sure you want to delete the \(selectedIndex.count) selected Quotes?"
        confirmationD.addButton(withTitle: "Ok")
        confirmationD.addButton(withTitle: "Cancel")
        confirmationD.alertStyle = .critical
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            columnsTable.beginUpdates()
            quotesArrayController.remove(atArrangedObjectIndexes: selectedIndex)
            columnsTable.endUpdates()
        }
    }
}




//MARK: - Extensions

//MARK: NSTableViewDelegate
extension CocoaBindingsTable: NSTableViewDelegate{
    //Dragging
    
}

extension CocoaBindingsTable: NSTableViewDataSource{
    
    //Dragging method accoridng to WWDC 2016
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        //let thisQuote2 = tableView.tableColumns[0].obj
        let thisQuote = (quotesArrayController.arrangedObjects as! NSArray).object(at: row) as? Quote
        let thisItem = NSPasteboardItem()
        thisItem.setString((thisQuote?.objectID.uriRepresentation().absoluteString)!, forType: .string)
        
        return thisItem
    }
}



//extension CocoaBindingsTable: NSSearchFieldDelegate{
//
//    //Gts called when user ends searhing
//    func searchFieldDidEndSearching(_ sender: NSSearchField) {
//        self.quotesArrayController.filterPredicate = nil
//        self.columnsTable.reloadData()
//        (self.parent as? ViewController)?.updateInfoLabel(parameter: "All")
//    }
//
//    //Gets called when user searches
//    override func controlTextDidChange(_ obj: Notification) {
//        let tempSearch = (obj.object as? NSSearchField)!.stringValue
//        if tempSearch != "" {
//            self.quotesArrayController.filterPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@", tempSearch)
//            self.columnsTable.reloadData()
//            (self.parent as? ViewController)?.updateInfoLabel(parameter: (self.quotesArrayController.arrangedObjects as! NSArray).count)
//        }
//    }
//}


