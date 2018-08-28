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
    @objc var myMOC: NSManagedObjectContext = (NSApp.delegate as! AppDelegate).managedObjectContext //TODO: Move to extension.
    
    lazy var listFRC:NSFetchedResultsController<LibraryItem> = {
        let fr=NSFetchRequest<LibraryItem>(entityName: Entities.library.rawValue)
        fr.sortDescriptors=[NSSortDescriptor(key: "name", ascending: true)]
        fr.predicate=startPredicate
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: myMOC, sectionNameKeyPath: nil, cacheName: nil)
        try! frc.performFetch() //TODO: This is dangerous!!! But datasource methods get called before viewDidLoad
        return frc
    }()
    
    @IBAction func bbb_test(_ sender: Any){
        print("bb_test")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        listView.expandItem(nil, expandChildren: true)
    }
    
}

//MARK: - NSTextFieldDelegate
extension LeftController: NSTextFieldDelegate {
    
    //Update search field when user enters text.
    override func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            let searchPredicate = NSPredicate(format: "name contains [CD] %@ AND isRootItem=NO", searchF.stringValue)
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
        return myCell
    }
    
    //Determines if triangle should be shown.
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        let libItem=item as? LibraryItem
        if !(libItem?.isRootItem)! && (libItem?.hasLibraryItems?.count)!>0 {
            return true
        }
        return false
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
}

