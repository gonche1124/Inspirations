//
//  MasterViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/22/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import Cocoa


class MasterViewController: NSViewController, NSTableViewDataSource{
    
    //Initialization code.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Properties and Outlets.
    @IBOutlet var quotesAC: NSArrayController!
    @IBOutlet var mainTableView: NSTableView?
    
    
    //MARK: - Actions.
    //Sets the selected quote(s) to favorite/unfavorite.
    @IBAction func setFavorite(_ sender: Any){
        
        guard let selectedQuotes=quotesAC.selectedObjects as? [Quote] else {return}
        if let menu = sender as? NSMenuItem{
            _=selectedQuotes.map({$0.isFavorite=(menu.identifier!.rawValue=="favorite") ? true : false})
        }
        if let keyStrike = sender as? Bool{
            _=selectedQuotes.map({$0.isFavorite=keyStrike})
        }
        try! self.moc.save()
        
    }
    
    
    //MARK: - Overrides.
    //Sets the information for the edit controller.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue=="editSegue", let destC = segue.destinationController as? AddQuote{
            try! self.moc.save()
            destC.title="Edit Quote"
            destC.representedObject=self.representedObject
            destC.selectedManagedObjects=quotesAC.selectedObjects as! [Quote]?
            destC.doneButtonText="Update"
            destC.moc.commitEditing()
        }
    }
    
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
    
    //Delete selected Records.
    override func deleteBackward(_ sender: Any?) {
        
        let totObjects = quotesAC.selectedObjects.count//columnsTable.selectedRowIndexes
        let confirmationD = NSAlert()
        
        confirmationD.messageText = "Delete Records"
        confirmationD.informativeText = "Are you sure you want to delete the \(totObjects) selected Quotes?"
        confirmationD.addButton(withTitle: "Ok")
        confirmationD.addButton(withTitle: "Cancel")
        confirmationD.alertStyle = .critical
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            self.mainTableView?.beginUpdates()
    
            //columnsTable.beginUpdates()
            quotesAC.selectedObjects.forEach({moc.delete($0 as! NSManagedObject)})
            //_=self.quotesArrayController.selectedObjects.map({moc.delete($0 as! NSManagedObject)})
            self.mainTableView?.endUpdates()
            
            // (self.representedObject as! SharedItems).mainQuoteController?.remove(atArrangedObjectIndexes: selectedIndex)
            //columnsTable.endUpdates()
        }
    }
    
    
    //MARK: - NSTableViewDataSource
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        
        //TODO: See if it works with selectedObjects.
        let thisQuote = (quotesAC.arrangedObjects as! NSArray).object(at: row) as? Quote
        let thisItem = NSPasteboardItem()
        thisItem.setString((thisQuote?.objectID.uriRepresentation().absoluteString)!, forType: .string)
        
        return thisItem
    }
    
    
}

