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
        (self.parent as? ViewController)?.searchQuote2.delegate=self
    }
    
    //Variables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //IBOutlets
    @IBOutlet var quotesArrayController: NSArrayController!
    @IBOutlet weak var columnsTable: NSTableView!
    
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
    
    //Dragging methods
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        //Set data to be pasted on pasteboard
        pboard.setData(NSKeyedArchiver.archivedData(withRootObject: rowIndexes), forType: NSPasteboard.PasteboardType.fileContents)

        return true
    }
}



extension CocoaBindingsTable: NSSearchFieldDelegate{
    
    //Gts called when user ends searhing
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.quotesArrayController.filterPredicate = nil
        self.columnsTable.reloadData()
        (self.parent as? ViewController)?.updateInfoLabel(parameter: "All")
    }
    
    //Gets called when user searches
    override func controlTextDidChange(_ obj: Notification) {
        let tempSearch = (obj.object as? NSSearchField)!.stringValue
        if tempSearch != "" {
            self.quotesArrayController.filterPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@", tempSearch)
            self.columnsTable.reloadData()
            (self.parent as? ViewController)?.updateInfoLabel(parameter: (self.quotesArrayController.arrangedObjects as! NSArray).count)
        }
    }
}


