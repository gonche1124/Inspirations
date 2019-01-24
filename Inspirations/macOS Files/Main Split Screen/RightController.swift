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
    
    //Variables:
    var deletesFromDatabase:Bool{
        return ![LibraryType.tag.rawValue, LibraryType.list.rawValue].contains(selectedLeftItem?.libraryType)
    }
    var selectedLeftItem:LibraryItem?{
        didSet{
            //print(selectedLeftItem)
            print("slectedleftItem-> updated")
        }
    }
    //{
//        didSet{
//            //let newBool = [LibraryType.tag.rawValue, LibraryType.list.rawValue].contains(selectedLeftItem?.libraryType)
//            //self.deletesFromDatabase = ![LibraryType.tag.rawValue, LibraryType.list.rawValue].contains(selectedLeftItem?.libraryType)
//        }
    //}
    var currentTable:NSTableView?
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedTabView(_:)), name: .selectedViewChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftTableChangedSelection(notification:)), name: .leftSelectionChanged, object: nil)
        let xx = self.quoteTabView.selectedTabViewItem
        quoteTabView.selectTabViewItem(xx)
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
            destinationSegue.isInfoWindow=true
            destinationSegue.currQuote=quoteController.selectedObjects.first as? Quote
            //destinationSegue.selectionController!.content=self.quoteController.selectedObjects
            //destinationSegue.selectionController!.setSelectedObjects(quoteController.selectedObjects)
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
                modifyFavoriteAttribute(!modFlags.contains(.shift)) //setFavorite(!modFlags.contains(.shift))
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
        //print("Called")
        if let selectedLib = notification.object as? LibraryItem,
            let newPredicate = NSPredicate.predicateFor(libraryItem: selectedLib){
            //print(selectedLib)
            self.selectedLeftItem=selectedLib
            self.quoteController.fetchPredicate=newPredicate
            self.quoteController.fetch(nil)
        }
    }
    
}

//MARK: - CRUD Core Data:
extension RightController{
    
    ///Updates favorite attribute based on sender parameter.
    @IBAction func modifyFavoriteAttribute(_ sender:Any){
        guard let selectedQuotes=quoteController.selectedObjects as? [Quote] else {return}
        
        //Using Batch Update to work efficiently.
        let selectedObjectsIDs=selectedQuotes.map{$0.objectID}
        let request=NSBatchUpdateRequest(entity: Quote.entity())
        request.predicate=NSPredicate(format: "self IN %@", selectedObjectsIDs)
        request.resultType = .updatedObjectIDsResultType
        let newBool = (sender as? AGC_NSMenuItem)?.agcBool ?? false
        request.propertiesToUpdate=["isFavorite": newBool]
        //TODO: Change to fire KVO
        
        do {
            let result = try moc.execute(request) as? NSBatchUpdateResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSUpdatedObjectsKey : objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
            //TODO. Figure out how to get notifications.
            let item=moc.getItem(ofType: .favorites)
            item?.belongsToLibraryItem?.willAccessValue(forKey: "name")
            item?.belongsToLibraryItem?.didAccessValue(forKey: "name")
            
        } catch {
            fatalError("Failed to perform batch update: \(error)")
        }
    }
    
    
    ///Adds the selected quotes to the tags or playlists specified.
    @IBAction func addTagsOrPlaylists(_ sender: NSMenuItem?){
        if let item=moc.get(objectWithStringID: sender!.identifier!.rawValue) as? ManagesQuotes & LibraryItem
        {
            item.addQuotes(quotes: self.quoteController?.selectedObjects as! [Quote])
            self.saveMainContext()
        }
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
            //self.saveMainContext()
        }
    }
}


//MARK: - NSTableViewDataSource
extension RightController: NSTableViewDataSource{
    
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
        //TODO: See if this can be done with bindings.
        case "rightMenu":
            if let deleteItem=menu.item(withIdentifier: "deleteMenuItem"){
                deleteItem.title=self.deletesFromDatabase ? "Delete":"Remove from \(self.selectedLeftItem?.name ?? "")"
            }
        case "tagMenu":
            menu.removeAllItems()
            try! Tag.allInContext(moc).forEach({
                menu.addMenuItem(title: $0.name!,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        case "listMenu":
            menu.removeAllItems()
            try! QuoteList.allInContext(moc).forEach({
                menu.addMenuItem(title: $0.name!,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        default:
            break
        }
    }
}
