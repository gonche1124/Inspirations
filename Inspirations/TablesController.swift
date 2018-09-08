//
//  TablesController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/19/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


//TODO: Make method that updates and reloads controller with given predicate
//TODO: Display right click menu to show delete, favorites, add to list, etc
import Cocoa

class TablesController: NSViewController {
    
    //Variables
    let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
    var deletesFromDatabase=false  //TODO: Implement
    var selectedLeftItem:LibraryItem? //TODO: Implement
    
    //let pred=NSPredicate(value: true)
    @IBOutlet weak var table: NSTableView?
    
    lazy var tableFRC:NSFetchedResultsController<Quote> = {
        let sortingO=NSSortDescriptor(key: "quoteString", ascending: true)
        fr.sortDescriptors=[sortingO]
        fr.predicate=NSPredicate(value: true)
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate=self
        try! frc.performFetch() //TODO: This is dangerous!!! But datasource methods get called before viewDidLoad
        return frc
    }() //as NSFetchedResultsController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        
        //Setup Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(leftTableChangedSelection(notification:)), name: .leftSelectionChanged, object: nil)
        
    }
    
    //USed to set as delegate the 
    override func viewDidAppear() {
        if let searchToolbarItem = view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue == "mainSearchField"}){
            if let sField = searchToolbarItem.view as? NSSearchField {
                sField.delegate=self
            }
        }
    }
    
    //Intercept keystrokes
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    //Delete selected Records.
    override func deleteBackward(_ sender: Any?) {
        let confirmationD = NSAlert()
        confirmationD.messageText = "Delete Records"
        confirmationD.informativeText = "Are you sure you want to delete the \(table?.numberOfSelectedRows) selected Quotes?"
        confirmationD.addButton(withTitle: "Ok")
        confirmationD.addButton(withTitle: "Cancel")
        confirmationD.alertStyle = .warning
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            self.table?.beginUpdates()
            table?.selectedRowIndexes.forEach({moc.delete(tableFRC.fetchedObjects![$0])})
            self.table?.endUpdates()
        }
    }
    
    //Left selection changed
    @objc func leftTableChangedSelection(notification: Notification){
        if let selectedLib = notification.object as? LibraryItem {
            let uPredicate: NSPredicate
            switch(selectedLib.libraryType){
            case LibraryType.favorites.rawValue:
                uPredicate = NSPredicate(format:"isFavorite == TRUE")
                self.deletesFromDatabase=false //TODO: Check if this can be done with a key value observer.
            case LibraryType.language.rawValue:
                uPredicate = NSPredicate(format: "isSpelledIn.name CONTAINS [CD] %@", selectedLib.name!)
                self.deletesFromDatabase=false
            case LibraryType.list.rawValue:
                self.deletesFromDatabase=true
                uPredicate = NSPredicate(format: "ANY isIncludedIn.name contains [CD] %@",  selectedLib.name!)//TODO: Make sure this predicate is working.
            case LibraryType.smartList.rawValue:
                uPredicate = ((selectedLib as? QuoteList)?.smartPredicate as? NSPredicate)!
            case LibraryType.tag.rawValue:
                self.deletesFromDatabase=true
                uPredicate = NSPredicate(format: "ANY isTaggedWith.name contains [CD] %@", selectedLib.name!)
            case LibraryType.mainLibrary.rawValue:
                uPredicate = NSPredicate(value: true)
                self.deletesFromDatabase=true
            default:
                uPredicate = NSPredicate(value: true)
            }
            self.selectedLeftItem=selectedLib
            self.updatesController(withPredicate: uPredicate)
        }
    }
    
    //Sets predicate passed as parameter to frc
    func updatesController(withPredicate predicate:NSPredicate){
        tableFRC.fetchRequest.predicate=predicate//(searchF.stringValue=="") ? pred: searchPredicate
        try! tableFRC.performFetch()
        self.table?.reloadData()
    }
    
}
//MARK: - NSFetchedResultsControllerDelegate
extension TablesController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.table?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.table?.reloadData()
        self.table?.endUpdates()
    }
}

//MARK: - NSSearchFieldDelegate
extension TablesController: NSSearchFieldDelegate {
    
    //Searchfield
    //TODO: Include a comprehensive predicate by using templates.
    //TODO: Simplify program flow
    override func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            if searchF.stringValue=="" {
                self.updatesController(withPredicate: NSPredicate(value: true))
            }else{
                let searchPredicate = NSPredicate(format: "quoteString contains [CD] %@ OR from.name contains [CD] %@ OR isAbout.themeName contains [CD] %@", searchF.stringValue, searchF.stringValue, searchF.stringValue)
                self.updatesController(withPredicate:searchPredicate)
            }
        }
    }
}

//MARK: - NSTableViewDataSource
extension TablesController: NSTableViewDataSource{
    
    //Total rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (tableFRC.fetchedObjects?.count)!
    }
    
    //Object for row number
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return tableFRC.fetchedObjects?[row]
    }
    
    //Copy Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        
        let thisQuote = tableFRC.fetchedObjects?[row]
        let thisItem = NSPasteboardItem()
        thisItem.setString((thisQuote?.objectID.uriRepresentation().absoluteString)!, forType: .string)
        return thisItem
    }
}

//MARK: - TableViewDelegate
extension TablesController: NSTableViewDelegate{
    
    //Displaying the cell
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let currQuote = self.tableFRC.fetchedObjects![row]
        if tableView.numberOfColumns==1 {
            let myCell = tableView.makeView(withIdentifier: .init("exploreCell"), owner: nil) as! ExploreCell
            myCell.authorField.stringValue=(currQuote.from?.name)!
            myCell.quoteField.stringValue=currQuote.quoteString!
            return myCell
        }
        else {
            let myCell = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as? NSTableCellView
            myCell?.textField?.stringValue = "\(currQuote.value(forKeyPath: (tableColumn?.identifier.rawValue)!) ?? "na")"
            myCell?.textField?.toolTip="\(currQuote.value(forKeyPath: (tableColumn?.identifier.rawValue)!) ?? "na")"
            return myCell
        }
    }
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            NotificationCenter.default.post(Notification(name: .selectedRowsChaged, object: myTable, userInfo: nil))
        }
    }

}

//TODO: Move into independent file


class ExploreCell: NSTableCellView{
    @IBOutlet weak var quoteField: NSTextField!
    @IBOutlet weak var authorField: NSTextField!
}



