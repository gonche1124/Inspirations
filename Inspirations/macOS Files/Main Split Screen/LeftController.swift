//
//  Left Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/26/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class LeftController: NSViewController {

    //Properties
    @IBOutlet weak var treeController:NSTreeController! //TO DELETE.
    @IBOutlet weak var listView: NSOutlineView!
    @IBOutlet weak var addButton:NSPopUpButton!
    
    @objc dynamic var canAddNewItem:Bool=false //Objc is neeed for key value
    @objc dynamic var canDeleteItem:Bool=false
    var selectedItem:LibraryItem?{
        didSet{
            self.updateBindings()
        }
    }
    
    lazy var listFRC:NSFetchedResultsController<LibraryItem> = {
        let fr=NSFetchRequest<LibraryItem>(entityName: Entities.library.rawValue)
        fr.sortDescriptors=[NSSortDescriptor(keyPath: \LibraryItem.sortingOrder, ascending: true), NSSortDescriptor(keyPath: \LibraryItem.name, ascending: true)]
        fr.predicate=NSPredicate.rootItems
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate=self
        try! frc.performFetch()
        return frc
    }()
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        //Regoster for dragging.
        self.listView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String as String)])
        //Register for changes in NSManagedObject relationsihp becasue listFRC only monitors one entity.
        
    }
    
    override func viewWillAppear() {
        listView.beginUpdates()
        listView.expandItem(nil, expandChildren: true)
        listView.endUpdates()
        
        //Set default selected item.
        let itemIndex = listView.row(forItem: moc.get(standardItem: .mainLibrary))
        listView.selectRowIndexes(IndexSet.init(integer: itemIndex), byExtendingSelection: false)
    }
 
    @IBAction func identifySegueToPerform(_ sender:Any){
        self.performSegue(withIdentifier: "genericIdentifier2", sender: sender)
    }
   
    
    /// Configure Smart List Controller and position caller.
    /// - NOTE: there is two point of origins, the button or the clicked row.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        //Makes sure the required info is in.
        guard let vc=segue.destinationController as? SmartListController,
            let clickedmenu = sender as? AGC_NSMenuItem,
            let segue=segue as? AGC_PopOverSegue else {
                return
        }
        
        //Defines the presenting view
        segue.presentingControl = clickedmenu.menu?.identifier?.rawValue=="rightClickMenu" ? listView : addButton
        segue.preferredEdge = clickedmenu.menu?.identifier?.rawValue=="rightClickMenu" ? .maxX : .maxY

        //Passes the selected library item and the type of action by user.
        vc.selectedObject=listView.item(atRow: listView.clickedRow) as? LibraryItem
        vc.typeOfAction = (clickedmenu.identifier!.rawValue=="editLibraryItem") ? .editing : .inserting
        vc.insertItemType = LibraryType(rawValue: clickedmenu.representedType)
    }
    
    
    
    //Deletes the selected item
    @IBAction func deleteItem(_ sender: Any){
        let itemToDelete:LibraryItem=listView.item(atRow: listView.selectedRow) as! LibraryItem
        if LibraryType.deletableItems.contains(itemToDelete.libraryType){
            self.moc.delete(itemToDelete)
            try! moc.save()
        }
    }
    
    //Updates canDelete and canAdd depending on objectValue
    //TODO: Check if this is worth it. Think how to optimize. With NSMenu it may not be worth it.
    func updateBindings(){
        let checkArray:[LibraryType]=[.favorites, .mainLibrary]
        let isRoot=(selectedItem?.isRootItem)!
        let isFolder=(selectedItem?.libraryType == .folder)
        let isMainFav=checkArray.contains((selectedItem?.libraryType)!)
        //let isPrincipal=selectedItem?.name=="Library"
        let isPrincipal=selectedItem?.libraryType == LibraryType.mainLibrary
        
        if isRoot && !isPrincipal {canAddNewItem=true; canDeleteItem=false}
        if !isRoot && !isMainFav && !isFolder{canAddNewItem=false; canDeleteItem=true}
        if isMainFav || isPrincipal {canDeleteItem=false; canAddNewItem=false}
    }
    
    /// Checks which items have had CRUD to determine if neccesary to update view.
    /// - TODO: Review performance and do case-by-case evaluation of updates.
//    @objc func managedObjectDidChange(notification: NSNotification){
//        listView.beginUpdates()
//        //listView.reloadData()
//        listView.endUpdates()
//    }
}

//MARK: - NSTextFieldDelegate
extension LeftController: NSTextFieldDelegate {
    
    //Update search field when user enters text.
    func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            listFRC.fetchRequest.predicate = NSPredicate(fromLeftSearchField: searchF)
            try! listFRC.performFetch()
            listView.beginUpdates()
            listView.reloadData()
            listView.expandItem(nil, expandChildren: true)
            listView.endUpdates()
        }
    }
    
    // Updates the predicate with the root items after the user ends searching.
    func controlTextDidEndEditing(_ obj: Notification) {
        listFRC.fetchRequest.predicate=NSPredicate.rootItems
        try! listFRC.performFetch()
        listView.beginUpdates()
        listView.reloadData()
        listView.expandItem(nil, expandChildren: true)
        listView.endUpdates()
    }
}

//MARK: - NSOutlineViewDelegate
extension LeftController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let libItem=item as? LibraryItem else {return nil}
        let identifier = (libItem.isRootItem) ? NSUserInterfaceItemIdentifier.headerCell : NSUserInterfaceItemIdentifier(rawValue: libItem.libraryType.rawValue)

        let myCell = outlineView.makeView(withIdentifier: identifier, owner: self) as? AGC_DataCell
        myCell?.textField?.stringValue=libItem.name
        if libItem.libraryType == .language, let localName = Locale.current.localizedString(forIdentifier: libItem.name){
            myCell?.textField?.stringValue=localName
        }
        if let totItems=libItem.totalQuotes, totItems>0{
            myCell?.totalButton?.isHidden=false
            myCell?.totalButton?.title="\(totItems)"
        }
        if libItem.isRootItem {
            myCell?.textField?.stringValue=libItem.name.uppercased()
        }
        return myCell
    }
    
    //Determines if triangle should be shown.
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        guard let libItem=item as? LibraryItem else {return false}
        return (libItem.isRootItem || libItem.libraryType == .folder) ? true : false
    }
    
    //Checks to see if it is a grouped item.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        guard let libItem=item as? LibraryItem else {return false}
        return libItem.isRootItem
    }
    
    //Return custom NSTableviewRow
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return LeftNSTableViewRow()
    }
    
   
    
    
    //Changes the selection
    func outlineViewSelectionDidChange(_ notification: Notification) {
        //Posts notification globally
        guard let outlineView = notification.object as? NSOutlineView else {return}
        guard let newItem = outlineView.item(atRow: outlineView.selectedRow) as? LibraryItem else {return}
        self.selectedItem=newItem
        //Sends global notification
        if !newItem.isRootItem {
                NotificationCenter.default.post(Notification(name: .leftSelectionChanged, object:newItem))
        }

    }
    
    /// Used to determine if the user can select the group objects of the table.
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let coreItem=item as? LibraryItem else {return false}
        return !coreItem.isRootItem
    }
}

//MARK: - NSOutlineViewDataSource Extension.
extension LeftController: NSOutlineViewDataSource {
    
    //Has to be efficient, gets called multiple times. (nil means root).
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item=item as? LibraryItem else {
            return (listFRC.fetchedObjects?.count)!
        }
        return (item.hasLibraryItems!.count)
    }
    
    //Check if it has children.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return ((item as? LibraryItem)?.hasLibraryItems?.count)!>0 ? true:false
    }
    
    //Return the item in a given position.
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
            guard let  libItem = item as? LibraryItem else {return listFRC.fetchedObjects![index]}
            return libItem.hasLibraryItems![index]
        
    }
    
    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    
        guard let destItem = item as? LibraryItem else {return NSDragOperation.init(rawValue: 0)}
        let canDragg2 = LibraryType.canDragg.contains(destItem.libraryType)
        return NSDragOperation.init(rawValue: canDragg2 ?  1 : 0)
        }
    
    //Perform the Drop, validating the data.
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    
            //WWDC 2016 method
            guard let stringArray = info.draggingPasteboard.pasteboardItems!.map({$0.string(forType:.string)}) as? [String],
                let quotesS = moc.getObjectsWithIDS(asStrings: stringArray) as? [Quote] else {
                    return false
            }
        
        if let destinatinoEntity = item as? ManagesQuotes{
            destinatinoEntity.addQuotes(quotes: quotesS)
            self.saveMainContext()
            return true
        }
            return false
        }
}

//MARK: - NSFetchedResultsControllerDelegate
extension LeftController: NSFetchedResultsControllerDelegate {
    
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
        print(#function)
        listView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        listView.reloadData()
        listView.expandItem(nil, expandChildren: true)
        listView.endUpdates()
    }
}

//MARK: - NSMenuDelegate Extension
extension LeftController: NSMenuDelegate{
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        //Get clickedObject.
        let selItem = listView.item(atRow: listView.clickedRow) as? LibraryItem
        let isRoot = selItem?.isRootItem ?? true
        let isFolder = (selItem?.libraryType == LibraryType.folder)
        let isFavOrMain = [LibraryType.favorites,LibraryType.mainLibrary, LibraryType.language].contains(selItem?.libraryType)
        
        //Enable or diable items:
        menu.items[AGCMENU.edit.rawValue].isEnabled = !isRoot && !isFavOrMain
        menu.items[AGCMENU.addTag.rawValue].isEnabled = (selItem?.name=="Tags")
        menu.items[AGCMENU.addList.rawValue].isEnabled = isFolder || (selItem?.name=="Lists")
        menu.items[AGCMENU.addSmartList.rawValue].isEnabled = isFolder || (selItem?.name=="Lists")
        menu.items[AGCMENU.addFolder.rawValue].isEnabled = isFolder || (selItem?.name=="Lists")
    }
}





