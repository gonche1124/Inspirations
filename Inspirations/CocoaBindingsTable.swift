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
//    override func viewWillAppear() {
//        super.viewWillAppear()
//
//    }
    
    //IBOutlets
    @IBOutlet var quotesArrayController: NSArrayController!
    @IBOutlet weak var columnsTable: NSTableView!
    @IBOutlet var authorsController: NSArrayController!
    @IBOutlet var themesController: NSArrayController!
    
    
    //Get keyboard keystrokes.
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
        //fn makes this flow happen.
        let modFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if modFlags.contains(.command) {
            switch event.characters{
            case "i":
                self.performSegue(withIdentifier:.init("editSegue"), sender: self)
            case "f":
                self.setFavorite(!modFlags.contains(.shift))
            default:
            break
            }
        }
       
    }
    
    //Command+I
    
    
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
        if segue.identifier?.rawValue=="editSegue", let destC = segue.destinationController as? AddQuote{
                destC.title="Edit Quote"
                destC.representedObject=self.representedObject
                destC.selectedManagedObjects=quotesArrayController.selectedObjects as! [Quote]?
                destC.doneButtonText="Update"
            }
        }
      
    
    
    //MARK: - Menu Actions
    //Marks as favorite the selected quotes.
    @IBAction func setFavorite(_ sender: Any) {
        
        guard let selectedQuotes=quotesArrayController.selectedObjects as? [Quote] else {       return}
        if let menu = sender as? NSMenuItem{
            _=selectedQuotes.map({$0.isFavorite=(menu.identifier!.rawValue=="favorite") ? true : false})
        }
        if let keyStrike = sender as? Bool{
            _=selectedQuotes.map({$0.isFavorite=keyStrike})
        }
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





