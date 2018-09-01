//
//  TablesController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/19/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class TablesController: NSViewController {
    
    //Variables
    //@objc var myMOC: NSManagedObjectContext = (NSApp.delegate as! AppDelegate).managedObjectContext
    let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
    let pred=NSPredicate(value: true)
    //var searchField: NSSearchField?
    var infoString: NSTextField?
    @IBOutlet weak var table: NSTableView?
    
    
    lazy var tableFRC:NSFetchedResultsController<Quote> = {
        let sortingO=NSSortDescriptor(key: "quoteString", ascending: true)
        fr.sortDescriptors=[sortingO]
        fr.predicate=pred
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate=self
        try! frc.performFetch() //TODO: This is dangerous!!! But datasource methods get called before viewDidLoad
        return frc
    }() //as NSFetchedResultsController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        //Link the searchfield.
        if let searchToolbarItem = view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue == "mainSearchField"}){
            if let sField = searchToolbarItem.view as? NSSearchField {
                  sField.delegate=self
            }
        }
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
    
    //HAS A BUG
    /*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
           table?.insertRows(at: IndexSet([newIndexPath!.item]), withAnimation: .slideDown)
        case .delete:
            
            let updated = max(min(indexPath!.item, (table?.numberOfRows)!-1),0)//TO circumvent bug
            print("Index is: \(indexPath?.item) and proxy is: \(updated) and totRows is: \(table?.numberOfRows)")
            self.table?.removeRows(at: IndexSet([updated]), withAnimation: .slideLeft) //BUG with out of bounds index
        case .update:
            print("update")
        case .move:
            print("move")
//            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//
//            if let newIndexPath = newIndexPath {
//                tableView.insertRows(at: [newIndexPath], with: .fade)
//            }
            break;
        }
    }
 */
    
    

}

//MARK: - NSSearchFieldDelegate
extension TablesController: NSSearchFieldDelegate {
    
    //Searchfield
    //TODO: Include a comprehensive predicate by using templates.
    override func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            let searchPredicate = NSPredicate(format: "quoteString contains [CD] %@ OR from.name contains [CD] %@ OR isAbout.themeName contains [CD] %@", searchF.stringValue, searchF.stringValue, searchF.stringValue)
            tableFRC.fetchRequest.predicate=(searchF.stringValue=="") ? pred: searchPredicate
            try! tableFRC.performFetch()
            self.table?.reloadData()
        }
    }
}

//MARK: - NSTableViewDataSource
extension TablesController: NSTableViewDataSource{
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (tableFRC.fetchedObjects?.count)!
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return tableFRC.fetchedObjects?[row]
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
            self.infoString?.stringValue = "\(myTable.numberOfSelectedRows) quotes out of \(myTable.numberOfRows)"
        }
    }

}

//TODO: Move into independent file


class ExploreCell: NSTableCellView{
    @IBOutlet weak var quoteField: NSTextField!
    @IBOutlet weak var authorField: NSTextField!
}



