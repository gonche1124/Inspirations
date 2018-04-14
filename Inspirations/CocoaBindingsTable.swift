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

    }
    
    //IBOutlets
    @IBOutlet var quotesArrayController: NSArrayController!
    @IBOutlet weak var columnsTable: NSTableView!
    @IBOutlet var authorsController: NSArrayController!
    @IBOutlet var themesController: NSArrayController!
    
//    override var representedObject: Any?{
//        didSet{
//            print("This was called \(self.description)")
//        }
//    }
    
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
            (self.representedObject as! SharedItems).mainQuoteController?.remove(atArrangedObjectIndexes: selectedIndex)            
            columnsTable.endUpdates()
        }
    }
    
    //Sets the information for the edit controller.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue=="editSegue" {
              print("Segue will perform.")
            let destSegue=segue.destinationController as? AddQuote
            destSegue?.title="Edit Quote"
            destSegue?.representedObject=self.representedObject
            destSegue?.view.layer?.backgroundColor=NSColor.red as! CGColor
            print("Segue will perform.2")
        }
      
    }
    
    //MARK: - Menu Actions
    //Marks as favorite the selected quotes.
    @IBAction func setFavorite(_ sender: NSMenuItem) {
        
        guard let selectedQuotes=self.quotesArrayController.selectedObjects as? [Quote] else {          return}
        
        _=selectedQuotes.map({$0.isFavorite=(sender.identifier!.rawValue=="favorite") ? true : false})
        try! self.moc.save()
        
        
    }
    
    //Edit the selected quote.
    @IBAction func editQuote(_ sender: NSMenuItem) {
        print ("edit quote")
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





