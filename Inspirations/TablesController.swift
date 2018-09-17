//
//  TablesController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/19/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


//TODO: Display right click menu to show delete, favorites, add to list, etc
import Cocoa

class TablesController: NSViewController {
    
    //Variables
    let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
    var deletesFromDatabase=false  //TODO: Implement
    var selectedLeftItem:LibraryItem? {
        didSet{
            let newBool = (selectedLeftItem?.libraryType == LibraryType.tag.rawValue || selectedLeftItem?.libraryType == LibraryType.list.rawValue)
            self.deletesFromDatabase=newBool
        }
    }
    
    
    //let pred=NSPredicate(value: true)
    @IBOutlet weak var table: NSTableView?
    
    @IBOutlet var menuToCorrectBug: NSMenu!
    
    lazy var tableFRC:GFetchResultsController<Quote> = {
        let sortingO=NSSortDescriptor(key: "quoteString", ascending: true)
        fr.sortDescriptors=[sortingO]
        fr.predicate=NSPredicate(value: true)
        let frc=GFetchResultsController(fetchRequest: fr, context: moc, Quote.self)
        frc.delegate=self
        frc.delegatedTable=self.table!
        //frc.associatedTable=self.table
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
    
    //Action upadte favorites.
    @IBAction func setFavorite(_ sender: Any){

        let newValue = (menu?.identifier!.rawValue == "favorite")
        self.tableFRC.selectedObjects?.forEach({$0.isFavorite=newValue})
        try! self.moc.save()
        
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
            self.tableFRC.selectedObjects?.forEach({moc.delete($0)})
            self.table?.endUpdates()
        }
        do{
            try self.moc.save()
        }catch{
            print(error)
        }
    }
    
    //Left selection changed
    @objc func leftTableChangedSelection(notification: Notification){
        if let selectedLib = notification.object as? LibraryItem,
            let newPredicate = NSPredicate.predicateFor(libraryItem: selectedLib){
                self.selectedLeftItem=selectedLib
                self.updatesController(withPredicate: newPredicate)
        }
    }
    
    //refresh table
    func refreshTable(){
        table?.beginUpdates()
        try! tableFRC.performFetch()
        self.table?.reloadData()
        table?.endUpdates()
    }
    
    //Sets predicate passed as parameter to frc
    func updatesController(withPredicate predicate:NSPredicate){
        tableFRC.fetchRequest.predicate=predicate
        self.refreshTable()
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
    override func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            let newPredicate=NSPredicate.mainFilter(withString: searchF.stringValue)
            self.updatesController(withPredicate: newPredicate)
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
    
    //Sorting was clicked on one of the columns.
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {return}
        self.tableFRC.fetchRequest.sortDescriptors=[sortDescriptor]
        self.refreshTable()
    }
}

//MARK: - TableViewDelegate
extension TablesController: NSTableViewDelegate{
    
    //Displaying the cell
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //Initial Setup
        let myCell = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! AGCCell
        let currQuote = self.tableFRC.fetchedObjects![row]
        myCell.objectValue=currQuote
        
        //Explore view
        if tableView.numberOfColumns==1 {return myCell}
        //Column View
        switch tableColumn?.identifier.rawValue {
            //case "from.name", "quoteString", "isAbout.themeName":
            //    myCell.objectValue=currQuote
            case "isFavorite":
                myCell.imageView?.image=NSImage.init(imageLiteralResourceName: ((currQuote.isFavorite) ? "red heart":"grey heart"))
            case "isTaggedWith":
                let tagArray = currQuote.isTaggedWith!
                myCell.textField?.stringValue = String(tagArray.count)
                myCell.textField?.toolTip = tagArray.compactMap({($0 as! Tag).name}).joined(separator: "\n")
            case "isIncludedIn":
                let listArray = currQuote.isIncludedIn!
                myCell.textField?.stringValue = String(listArray.count)
                myCell.textField?.toolTip = listArray.compactMap({($0 as! QuoteList).name}).joined(separator: "\n")
            default:
                return myCell
        }
        return myCell
        
    
    }
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            NotificationCenter.default.post(Notification(name: .selectedRowsChaged, object: myTable, userInfo: nil))
        }
    }

}

//TODO: Move into independent file


class AGCCell: NSTableCellView{

    //Custom Outlets
    @IBOutlet weak var quoteField: NSTextField?
    @IBOutlet weak var authorField: NSTextField?

    
    override var backgroundStyle: NSView.BackgroundStyle {
        willSet {
            if newValue == .dark {
                quoteField?.textColor = NSColor.controlLightHighlightColor
                authorField?.textColor = NSColor.controlHighlightColor
            } else {
                quoteField?.textColor = NSColor.labelColor
                authorField?.textColor = NSColor.controlShadowColor
            }
        }
    }
}



