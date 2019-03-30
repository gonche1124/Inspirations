//
//  RightController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/26/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class RightController: NSViewController {
    
    //Outlets:
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var quoteTabView:NSTabView!
    @IBOutlet weak var bottomStackView:NSStackView!
    @IBOutlet weak var rightMenu:NSMenu!
    
    //Tables
    @IBOutlet weak var columnTable:NSTableView?
    @IBOutlet weak var exploreTable:NSTableView?
    var selectedLeftItem:LibraryItem?
    var currentTable:NSTableView?
    
    
    lazy var quoteFRC:NSFetchedResultsController<Quote> = {
        let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
        fr.sortDescriptors = [NSSortDescriptor(keyPath: \Quote.quoteString, ascending: true)]
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate=self
        try! frc.performFetch()
        return frc
        //TODO: Check before loading if there are any filters active or a different item selectedd.
    }()
    
    //Variables:
    var deletesFromDatabase:Bool{
        return LibraryType.canDeleteQuotes.contains(selectedLeftItem?.libraryType ?? .mainLibrary)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedTabView(_:)), name: .selectedViewChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftTableChangedSelection(notification:)), name: .leftSelectionChanged, object: nil)
        
        //Binds the table.
        if let currT = self.view.getAllSubViews().firstWith(identifier: "columnTable"), let table=currT as? NSTableView{
                self.currentTable=table
        }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        print("viewWillAppear")
        
    }
    
    override func viewDidAppear() {
        if let searchToolbarItem = view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue == "mainSearchField"}){
            if let sField = searchToolbarItem.view as? NSSearchField {
                sField.delegate = self
            }
        }
    }
    
    //Called before preparing for a segue.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let destinationSegue = segue.destinationController as? AddQuoteController{
            if let table = currentTable{
                let currQuote = quoteFRC.object(at: IndexPath(item: table.selectedRow, section: 0))
                destinationSegue.currQuote=currQuote//quoteController.selectedObjects.first as? Quote
                destinationSegue.viewType = .showing
            }
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
                performSegue(withIdentifier:.init("editSegue"), sender: self)
            case "f":
                let virtualmenu = AGC_NSMenuItem.init(withBool: !modFlags.contains(.shift))
                modifyFavoriteAttribute(virtualmenu)
            default:
                break
            }
        }
    }
    
    //MARK: -
    //Changes the TAB View.
    @IBAction func changeSelectedTabView(_ sender: Any){
        if let segmentedControl = (sender as? NSNotification)?.object as? NSSegmentedControl{
            quoteTabView.selectTabViewItem(at: segmentedControl.selectedSegment)
            let tabViewItem = quoteTabView.selectedTabViewItem
            if let tableView = tabViewItem?.view?.getAllSubViews().firstWith(identifier: "columnTable"), let table=tableView as? NSTableView{
                currentTable=table
                currentTable?.reloadData()
                bottomStackView.isHidden=false
                return
            }
            if let tableView = tabViewItem?.view?.getAllSubViews().firstWith(identifier: "exploreTable"), let table=tableView as? NSTableView{
                currentTable=table
                currentTable?.reloadData()
                bottomStackView.isHidden=false
                return
            }
            currentTable=nil
            bottomStackView.isHidden=true
            
        }
    }
    
    //Left selection changed
    @objc func leftTableChangedSelection(notification: Notification){
        if let selectedLib = notification.object as? LibraryItem {
            self.selectedLeftItem=selectedLib
            self.quoteFRC.fetchRequest.predicate=selectedLib.quotePredicate
            try? quoteFRC.performFetch()
            currentTable?.reloadData()
        }
    }
    
}

//MARK: - CRUD Core Data:
extension RightController{
    
    ///Updates favorite attribute based on sender parameter.
    @IBAction func modifyFavoriteAttribute(_ sender:AGC_NSMenuItem){
        
        let indexPathArray = currentTable!.selectedRowIndexes.map{IndexPath(item: $0, section: 0)}
        let selectedQuotes = indexPathArray.map{quoteFRC.object(at: $0)}
        let selectedIDs = selectedQuotes.map{$0.objectID}
        
        //Using Batch Update to work efficiently.
        let request=NSBatchUpdateRequest(entity: Quote.entity())
        request.predicate=NSPredicate(format: "self IN %@", selectedIDs)
        request.resultType = .updatedObjectIDsResultType
        request.propertiesToUpdate=["isFavorite": sender.agcBool]
        self.pContainer.performBackgroundTask{(context) in
            do {
                if let result = try context.execute(request) as? NSBatchUpdateResult,let objectIDArray = result.result as? [NSManagedObjectID]{
                    let changes:[AnyHashable : Any] = [NSUpdatedObjectsKey : objectIDArray]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
                }
                
            } catch {
                fatalError("Failed to perform batch update: \(error)")
            }
        }
    }
    
    
    ///Adds the selected quotes to the tags or playlists specified.
    @IBAction func addTagsOrPlaylists(_ sender: NSMenuItem?){
        if let item = moc.getObjectsWithIDS(asStrings: [sender!.identifier!.rawValue])?.first as? ManagesQuotes & LibraryItem{
            let selectedQuotes = currentTable!.selectedRowIndexes.map({IndexPath(item: $0, section: 0)}).map{quoteFRC.object(at: $0)}
            item.addQuotes(quotes: selectedQuotes)
            //item.addQuotes(quotes: self.quoteController?.selectedObjects as! [Quote])
            self.saveMainContext()        }
    }
    
    //Deletes selected record or records.
    @IBAction func deleteSelectedRecord(_ sender: Any?){
       
        let confirmationD = NSAlert.init(totalItems: currentTable?.numberOfSelectedRows ?? 0, isDeleting: self.deletesFromDatabase)
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            currentTable?.beginUpdates()
             let selectedObjects=currentTable!.selectedRowPaths.map{quoteFRC.object(at: $0)}
            if deletesFromDatabase {
                selectedObjects.forEach({moc.delete($0)})
            }else{
                if let item=selectedLeftItem as? ManagesQuotes{
                    item.removeQuotes(quote: selectedObjects) //quoteController.selectedObjects as! [Quote])
                }
            }
            currentTable?.endUpdates()
            self.saveMainContext()
        }
    }
}


//MARK: - NSTableViewDataSource
extension RightController: NSTableViewDataSource{
    //WHEN NO BINDINGS USED:
    func numberOfRows(in tableView: NSTableView) -> Int {
        return quoteFRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if quoteFRC.fetchedObjects?.count ?? 0 > row {
            return quoteFRC.fetchedObjects?[row]
        }
        return quoteFRC.fetchedObjects?.last
        //return quoteFRC.object(at: IndexPath(item: row-1, section: 0))
    }
    
    /// Used for sorting of columns.
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {return}
        quoteFRC.fetchRequest.sortDescriptors = [sortDescriptor]
        try? quoteFRC.performFetch()
        currentTable?.beginUpdates()
        currentTable?.reloadData()
        currentTable?.endUpdates()
    }
    //WHEN NO BINDINGS USED
    
    
    //Copy-Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let thisQuote = quoteFRC.object(at: IndexPath(item: row, section: 0))
        let thisItem = NSPasteboardItem()
        thisItem.setString(thisQuote.getID(), forType: .string)
        return thisItem
    }
}

//MARK: - TableViewDelegate
extension RightController: NSTableViewDelegate{
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let table = notification.object as? NSTableView
             {
                let objects = table.selectedRowPaths.map({quoteFRC.object(at: $0)}).map({$0.getID()})
            NotificationCenter.default.post(Notification(name: .rightSelectedRowsChaged,
                                                         object: objects,
                                                         userInfo: nil)) //Used for displaying text and for sharing selected Objects
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension RightController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type){
        case .delete:
            //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            print("Delete")
            break
        case .insert:
            //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            print("Insert")
            break
        case .move:
            //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            print("Move")
            break
        case .update:
            // [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            print("Update..........")
            break
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentTable!.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentTable!.reloadData()
        currentTable!.endUpdates()
    }
}

//MARK: - NSMenuDelegate
extension RightController: NSMenuDelegate{
    
    //Called before being shown
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        switch menu.identifier?.rawValue {
        case "rightMenu":
            if let deleteItem=menu.item(withIdentifier: "deleteMenuItem"){
                deleteItem.title="Remove from \(self.selectedLeftItem?.name ?? "")"
            }
        case "tagMenu":
            menu.removeAllItems()
            try! Tag.objects(in: moc).forEach({
                menu.addMenuItem(title: $0.name,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        case "listMenu":
            menu.removeAllItems()
            try! QuoteList.objects(in: moc, with: NSPredicate(forItem: .list)).forEach({
                menu.addMenuItem(title: $0.name,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        default:
            break
        }
    }
}

// MARK: -
extension RightController: NSSearchFieldDelegate {
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.quoteFRC.fetchRequest.predicate=selectedLeftItem!.quotePredicate
        try? quoteFRC.performFetch()
        currentTable?.beginUpdates()
        currentTable?.reloadData()
        currentTable?.endUpdates()
        
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let searchField = obj.object as? NSSearchField,
            searchField.stringValue.count > 0 {
            quoteFRC.fetchRequest.predicate=NSCompoundPredicate(ORcompundWithText: searchField.stringValue)
            try? quoteFRC.performFetch()
            currentTable?.beginUpdates()
            currentTable?.reloadData()
            currentTable?.endUpdates()
        }
    }
}
