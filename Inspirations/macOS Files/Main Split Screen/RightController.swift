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
    @IBOutlet weak var quoteController:NSArrayController!
    @IBOutlet weak var quoteTabView:NSTabView!
    @IBOutlet weak var bottomStackView:NSStackView!
    
    //Tables
    @IBOutlet weak var columnTable:NSTableView?
    @IBOutlet weak var listTable:NSTableView?
    
    lazy var listFRC:NSFetchedResultsController<Quote> = {
        //let fr=LibraryItem.fetchRequestForEntity(inContext: <#T##NSManagedObjectContext#>)
        let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
        //TODO: use keypaths: https://stoeffn.de/posts/modern-core-data-in-swift/
        fr.sortDescriptors=[NSSortDescriptor(key: "quoteString", ascending: true)]
        //fr.predicate=nil
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        //frc.delegate=self
        try! frc.performFetch()
        return frc
    }()
    
    //Variables:
    var deletesFromDatabase:Bool{
        return LibraryType.canDeleteQuotes.contains(selectedLeftItem?.libraryType ?? .mainLibrary)
    }
    
    var selectedLeftItem:LibraryItem?
    var currentTable:NSTableView?
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedTabView(_:)), name: .selectedViewChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftTableChangedSelection(notification:)), name: .leftSelectionChanged, object: nil)
        
        //Binds the table.
        if let currT = self.view.getAllSubViews().firstWith(identifier: "columnTable"), let table=currT as? NSTableView{
                self.currentTable=table
        }
    }
    
    override func viewDidAppear() {
        if let searchToolbarItem = view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue == "mainSearchField"}){
            if let sField = searchToolbarItem.view as? NSSearchField {
                
                //All
                sField.bind(NSBindingName.predicate, to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"All",NSBindingOption.predicateFormat:pAll])
                
                //Author
                sField.bind(NSBindingName(rawValue: "predicate2"), to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"Author",NSBindingOption.predicateFormat:pAuthor])
                
                //Theme
                sField.bind(NSBindingName(rawValue: "predicate3"), to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"Theme",NSBindingOption.predicateFormat:pTheme])
            }
        }
    }
    
    //Called before preparing for a segue.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let destinationSegue = segue.destinationController as? AddQuoteController{
            destinationSegue.currQuote=quoteController.selectedObjects.first as? Quote
            destinationSegue.viewType = .showing
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
                bottomStackView.isHidden=false
                return
            }
            if let tableView = tabViewItem?.view?.getAllSubViews().firstWith(identifier: "exploreTable"), let table=tableView as? NSTableView{
                currentTable=table
                bottomStackView.isHidden=false
                return
            }
            currentTable=nil
            bottomStackView.isHidden=true
            
        }
    }
    
    //Left selection changed
    @objc func leftTableChangedSelection(notification: Notification){
        if let selectedLib = notification.object as? LibraryItem,
            let newPredicate = NSPredicate.quotePredicate(for: selectedLib){
            self.selectedLeftItem=selectedLib
            self.quoteController.fetchPredicate=newPredicate
            self.quoteController.fetch(nil)
        }
    }
    
}

//MARK: - CRUD Core Data:
extension RightController{
    
    ///Updates favorite attribute based on sender parameter.
    @IBAction func modifyFavoriteAttribute(_ sender:AGC_NSMenuItem){
        guard let selectedQuotes=quoteController.selectedObjects as? [Quote] else {return}
        
        //Using Batch Update to work efficiently.
        let request=NSBatchUpdateRequest(entity: Quote.entity())
        request.predicate=NSPredicate(format: "self IN %@", selectedQuotes.map{$0.objectID})
        request.resultType = .updatedObjectIDsResultType
        request.propertiesToUpdate=["isFavorite": sender.agcBool]
        
        do {
            if let result = try moc.execute(request) as? NSBatchUpdateResult,let objectIDArray = result.result as? [NSManagedObjectID]{
                let changes:[AnyHashable : Any] = [NSUpdatedObjectsKey : objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
            }
            
        } catch {
            fatalError("Failed to perform batch update: \(error)")
        }
    }
    
    
    ///Adds the selected quotes to the tags or playlists specified.
    @IBAction func addTagsOrPlaylists(_ sender: NSMenuItem?){
        if let item = moc.getObjectsWithIDS(asStrings: [sender!.identifier!.rawValue])?.first as? ManagesQuotes & LibraryItem{
            item.addQuotes(quotes: self.quoteController?.selectedObjects as! [Quote])
            self.saveMainContext()        }

    }
    
    //Deletes selected record or records.
    @IBAction func deleteSelectedRecord(_ sender: Any?){
       
        
        let confirmationD = NSAlert.init(totalItems: currentTable?.numberOfSelectedRows ?? 0, isDeleting: self.deletesFromDatabase)
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            currentTable?.beginUpdates()
            if deletesFromDatabase {
                let selectedObjects=quoteController.selectedObjects as! [Quote]
                selectedObjects.forEach({moc.delete($0)})
            }else{
                if let item=selectedLeftItem as? ManagesQuotes{
                    item.removeQuotes(quote: quoteController.selectedObjects as! [Quote])
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
        return listFRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return listFRC.object(at: IndexPath(item: row, section: 0))
    }
    //WHEN NO BINDINGS USED:
    
    
    //Copy-Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let thisQuote = (quoteController.arrangedObjects as! [Quote])[row]
        let thisItem = NSPasteboardItem()
        thisItem.setString(thisQuote.getID(), forType: .string)
        return thisItem
    }
}

//MARK: - TableViewDelegate
extension RightController: NSTableViewDelegate{
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let _ = notification.object as? NSTableView,
            let selectedArray = self.quoteController.selectedObjects as? [Quote] {
            NotificationCenter.default.post(Notification(name: .selectedRowsChaged,
                                                         object: selectedArray.map({$0.getID()}),
                                                         userInfo: nil)) //Used for displaying text and for sharing selected Objects
        }
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
            try! QuoteList.objects(in: moc, with: NSPredicate.forItem(ofType: .list)).forEach({
                menu.addMenuItem(title: $0.name,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        default:
            break
        }
    }
}
