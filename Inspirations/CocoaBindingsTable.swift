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
        if let searchField = self.mainSearchField as? NSSearchField, let quoteC = quotesArrayController {
            self.bind(searchField: searchField, toQuoteController: quoteC)
        }
        
        //Bind Information Label.
        if let infoL = NSApp.mainWindow?.contentView?.viewWithTag(1) as? NSTextField{
            self.bind(infoLabel: infoL,
                      toQuotes: quotesArrayController,
                      andAuthor: authorsController,
                      andThemes: themesController)
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

//extension CocoaBindingsTable: ControllerProtocol {
//    override var currentQuoteController: NSArrayController? {
//        return quotesArrayController
//    }
//
//    var currentAuthorController: NSArrayController? {
//        return authorsController
//    }
//
//    var currentThemesController: NSArrayController? {
//        return themesController
//    }
//
//    var currentTagsController: NSArrayController? {
//        return nil
//    }
//
//
//}



