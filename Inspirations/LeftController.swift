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
    @IBOutlet weak var listView: NSOutlineView!
    
    let startPredicate=NSPredicate(format: "isRootItem == YES")
 
    lazy var listFRC:NSFetchedResultsController<LibraryItem> = {
        let fr=NSFetchRequest<LibraryItem>(entityName: Entities.library.rawValue)
        fr.sortDescriptors=[NSSortDescriptor(key: "name", ascending: true)]
        fr.predicate=startPredicate
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate=self
        try! frc.performFetch() //TODO: This is dangerous!!! But datasource methods get called before viewDidLoad
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        //Regoster for dragging.
        self.listView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String as String)])
        listView.expandItem(nil, expandChildren: true)
    
    }
}

//MARK: - NSTextFieldDelegate
extension LeftController: NSTextFieldDelegate {
    
    //Update search field when user enters text.
    override func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            let searchPredicate = NSPredicate(format: "(name contains [CD] %@ AND isRootItem=NO)", searchF.stringValue)
            listFRC.fetchRequest.predicate=(searchF.stringValue=="") ? startPredicate:searchPredicate
            try! listFRC.performFetch()
            listView.reloadData()
            listView.expandItem(nil, expandChildren: true)
        }
    }
}

//MARK: - NSOutlineViewDelegate
extension LeftController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var myCell: NSTableCellView?
        let libItem=(item as? LibraryItem)
        let typeOfCell:String=(libItem?.isRootItem)! ? "HeaderCell":"DataCell"
        myCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: typeOfCell), owner: self) as? NSTableCellView
        myCell?.textField?.stringValue=(libItem?.name!)!
        guard let itemImage = NSImage(named: NSImage.Name((libItem?.libraryType)!)) else {
            myCell?.imageView?.image=NSImage.init(named: .folder) //TODO: make it right with an NSIMAGE extensions?
            return myCell
        }
        myCell?.imageView?.image=itemImage
        return myCell
    }
    
    //Determines if triangle should be shown.
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        let libItem=item as? LibraryItem
        return !(libItem?.isRootItem)! && (libItem?.hasLibraryItems?.count)!>0
//        if !(libItem?.isRootItem)! && (libItem?.hasLibraryItems?.count)!>0 {
//            return true
//        }
//        return false
    }
    
    //Changes the selection
    func outlineViewSelectionDidChange(_ notification: Notification) {
        //Posts notification globally
        if let outlineView = notification.object as? NSOutlineView,
            outlineView.selectedRowIndexes.count==1,
            let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? LibraryItem,
            !selectedItem.isRootItem {
                NotificationCenter.default.post(Notification(name: .leftSelectionChanged, object:selectedItem))
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
    
    //Retursn the item in a given position.
    //TODO: Simplify
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return listFRC.fetchedObjects![index]
        }
        else{
            return (item as? LibraryItem)?.hasLibraryItems![index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return listFRC.fetchedObjects
    }
    
    //Required for editing.
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
    }
    
    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    
        guard let destItem = item as? LibraryItem else {
                return NSDragOperation.init(rawValue: 0)
            }
        let canDragg = (!destItem.isRootItem && (destItem.libraryType == LibraryType.list.rawValue || destItem.libraryType == LibraryType.tag.rawValue))
        return NSDragOperation.init(rawValue: canDragg ?  1 : 0)
        }
    
        //Perform the Drop, validating the data.
        func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    
            //WWDC 2016 method
            let sURL: [URL] = info.draggingPasteboard().pasteboardItems!.map({URL.init(string: $0.string(forType: .string)!)!})
            let sOBID: [NSManagedObjectID] = sURL.map({(moc.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0))!})
            let quotesS = sOBID.map({moc.object(with: $0 )})
    
            if let destTag = item as? Tag{
                destTag.addToHasQuotes(NSSet(array: quotesS))
                return true
            }
            if let destList = item as? QuoteList {
                destList.addToHasQuotes(NSSet(array: quotesS))
                return true
            }
            return false
        }
}

//MARK: - NSFetchedResultsControllerDelegate
extension LeftController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listView.reloadData()
        listView.expandItem(nil, expandChildren: true)
        listView.endUpdates()
    }
}

