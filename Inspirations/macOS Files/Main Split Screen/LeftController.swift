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
    @objc dynamic var canAddNewItem:Bool=false //Objc is neeed for key value
    @objc dynamic var canDeleteItem:Bool=false
    var selectedItem:LibraryItem?{
        didSet{
            self.updateBindings()
        }
    }
    
    lazy var listFRC:NSFetchedResultsController<LibraryItem> = {
        let fr=NSFetchRequest<LibraryItem>(entityName: Entities.library.rawValue)
        fr.sortDescriptors=[NSSortDescriptor(key: "sortingOrder", ascending: true),NSSortDescriptor(key: "name", ascending: true)]
        fr.predicate=NSPredicate.leftPredicate(withText: "")
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate=self
        try! frc.performFetch()
        return frc
    }()
    
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
        
        //Register to update count.
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectDidChange), name: .NSManagedObjectContextObjectsDidChange, object: self.moc)
    }
 
    
    //Configure Smart List Controller in case the list already exists.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let editController=segue.destinationController as? SmartListController,
            sender is NSMenuItem{
            editController.selectedObject=listView.item(atRow: listView.selectedRow) as? LibraryItem
            editController.title="Edit Item"
        }
        if let editController=segue.destinationController as? SmartListController, sender is NSButton{
            editController.leftVC=self
            editController.title="New Item"
        }
    }
    
    //Deletes the selected item
    @IBAction func deleteItem(_ sender: Any){
        let itemToDelete:LibraryItem=listView.item(atRow: listView.selectedRow) as! LibraryItem
        if [LibraryType.list.rawValue,LibraryType.smartList.rawValue, LibraryType.tag.rawValue ].contains(itemToDelete.libraryType){
            self.moc.delete(itemToDelete)
            try! moc.save()
        }
    }
    
    //Updates canDelete and canAdd depending on objectValue
    func updateBindings(){
        let checkArray=[LibraryType.favorites.rawValue, LibraryType.mainLibrary.rawValue]
        let isRoot=(selectedItem?.isRootItem)!
        let isFolder=selectedItem?.libraryType==LibraryType.folder.rawValue
        let isMainFav=checkArray.contains((selectedItem?.libraryType)!)
        let isPrincipal=selectedItem?.name=="Library"
        
        if isRoot && !isPrincipal {canAddNewItem=true; canDeleteItem=false}
        if !isRoot && !isMainFav && !isFolder{canAddNewItem=false; canDeleteItem=true}
        if isMainFav || isPrincipal {canDeleteItem=false; canAddNewItem=false}
    }
    
    ///Checks which items have had CRUD to determine if neccesary to update view.
    @objc func managedObjectDidChange(notification: NSNotification){
        listView.beginUpdates()
        listView.reloadData()
        listView.endUpdates()
        //TODO: Review performance and do case-by-case evaluation of updates.
        
    }
}

//MARK: - NSTextFieldDelegate
extension LeftController: NSTextFieldDelegate {
    
    //Update search field when user enters text.
    func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            listFRC.fetchRequest.predicate=NSPredicate.leftPredicate(withText: searchF.stringValue)
            try! listFRC.performFetch()
            listView.beginUpdates()
            listView.reloadData()
            listView.expandItem(nil, expandChildren: true)
            listView.endUpdates()
        }
    }
}

//MARK: - NSOutlineViewDelegate
extension LeftController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let libItem=item as? LibraryItem, let type=libItem.libraryType
             else {return nil}
        let identifier=NSUserInterfaceItemIdentifier(type)
        let myCell = outlineView.makeView(withIdentifier: identifier, owner: self) as? AGC_DataCell
        myCell?.textField?.stringValue=libItem.name!
        if let totItems=libItem.totalQuotes, totItems>0{
            myCell?.totalButton?.isHidden=false
            myCell?.totalButton?.title="\(totItems)"
        }
        if libItem.isRootItem {
            myCell?.textField?.stringValue=libItem.name!.uppercased()
        }
        
//        if libItem.isRootItem {
//            let myCell = outlineView.makeView(withIdentifier:.headerCell, owner: self) as? NSTableCellView
//            myCell?.textField?.stringValue=libItem.name!
//            return myCell
//        }else{
//            let myCell = outlineView.makeView(withIdentifier: .dataCell, owner: self) as? AGC_DataCell
//            myCell?.textField?.stringValue=libItem.name!
//            myCell?.imageView?.image=NSImage.init(named: NSImage.Name(libItem.libraryType!))
//            myCell?.totalButton?.isHidden=true
//            if let totItems=libItem.totalQuotes, totItems>0{
//                myCell?.totalButton?.isHidden=false
//                myCell?.totalButton?.title="\(totItems)"
//            }
//            return myCell
//        }
        return myCell
    }
    
    //Determines if triangle should be shown.
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        guard let libItem=item as? LibraryItem else {return false}
        if libItem.isRootItem || libItem.libraryType == LibraryType.folder.rawValue{
            return true
        }
        return false
        //return (libItem?.isRootItem)!
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
}

//MARK: - NSOutlineViewDataSource Extension.
extension LeftController: NSOutlineViewDataSource {
    
    //Has to be efficient, gets called multiple times. (nil means root).
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return (listFRC.fetchedObjects?.count)!
        }
        else {
            return ((item as? LibraryItem)?.hasLibraryItems!.count)!
        }
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
    
    
    //Required for editing.
    //TODO: Research if this is the best place to set the object of a cell for future the binding.
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
    }
    
    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    
        guard let destItem = item as? LibraryItem else {return NSDragOperation.init(rawValue: 0)}
        let canDragg = (!destItem.isRootItem && (destItem.libraryType == LibraryType.list.rawValue || destItem.libraryType == LibraryType.tag.rawValue))
        return NSDragOperation.init(rawValue: canDragg ?  1 : 0)
        }
    
        //Perform the Drop, validating the data.
        func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    
            //WWDC 2016 method
            guard let stringArray = info.draggingPasteboard.pasteboardItems!.map({$0.string(forType:.string)}) as? [String],
                let quotesS = moc.getObjectsWithIDS(asStrings: stringArray) as? [Quote] else {
                    return false
            }
    
            if let destTag = item as? Tag{
                destTag.addToHasQuotes(NSSet(array: quotesS))
                try! self.moc.save()
                return true
            }
            if let destList = item as? QuoteList {
                destList.addToHasQuotes(NSSet(array: quotesS))
                try! self.moc.save()
                return true
            }
            return false
        }
}

//MARK: - NSFetchedResultsControllerDelegate
extension LeftController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listView.beginUpdates()
        print("controllerWillChangeContent")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        print("controllerDidChangeContent")
        listView.reloadData()
        listView.expandItem(nil, expandChildren: true)
        listView.endUpdates()
    }
}





