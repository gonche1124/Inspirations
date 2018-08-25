//
//  AlternateController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/25/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class AlternateController2: NSViewController {
   

    @IBOutlet weak var tabContainer: NSView!
    
    //Properties
    @IBOutlet weak var listView: NSOutlineView!
    
    @IBOutlet weak var tableSearchField: NSSearchField!
    
    @IBOutlet weak var statusTextField: NSTextField!
    @objc var myMOC: NSManagedObjectContext = (NSApp.delegate as! AppDelegate).managedObjectContext
    let fr=NSFetchRequest<LibraryItem>(entityName: Entities.library.rawValue)
    let pred=NSPredicate(format: "isRootItem == YES")

    lazy var mainSearchField:NSSearchField? = {
        var thisSearchBar:NSSearchField?
        //let searchToolBarItem = (NSApp.mainWindow?.toolbar?.items)?.first(where: {$0.itemIdentifier.rawValue; "mainSearchField"}){
            
        //}
        return thisSearchBar!
    }()
    
    //let parentWindowController =//self.view.window.toolbar as! NSToolbar

    
    lazy var listFRC:NSFetchedResultsController<LibraryItem> = {
        //let fr=NSFetchRequest<LibraryItem>(entityName: Entities.library.rawValue)
        //let pred=NSPredicate(format: "isRootItem == YES")
        let sortingO=NSSortDescriptor(key: "name", ascending: true)
        fr.sortDescriptors=[sortingO]
        fr.predicate=pred
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: myMOC, sectionNameKeyPath: nil, cacheName: nil)
        try! frc.performFetch() //TODO: This is dangerous!!! But datasource methods get called before viewDidLoad
        return frc
    }() //as NSFetchedResultsController
   
    @IBAction func changeTabView(_ sender: NSSegmentedControl){
        if let tabViewController = self.childViewControllers[0] as? NSTabViewController{
            tabViewController.selectedTabViewItemIndex=sender.selectedSegment //TODO: Check if can sync, if not to make select tab.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Custom loading Setup
        listView.expandItem(nil, expandChildren: true)
    }
    
    //Used to pass data between storyboards/segues.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let tabsController = segue.destinationController as? NSTabViewController {
            for tabItem in tabsController.tabViewItems {
                if let viewController = tabItem.viewController as? TablesController {
                    viewController.searchField=tableSearchField
                    viewController.infoString=statusTextField
                }
            }
        }
        
    }
    
    @IBAction func deleteSelectedLibraryItem(_ sender: Any) {
    }
    
    //Update search field when user enters text.
    override func controlTextDidChange(_ obj: Notification) {
        if let searchF = obj.object as? NSSearchField {
            let searchPredicate = NSPredicate(format: "name contains [CD] %@ AND isRootItem=NO", searchF.stringValue)
            listFRC.fetchRequest.predicate=(searchF.stringValue=="") ? pred:searchPredicate
            try! listFRC.performFetch()
            listView.reloadData()
            listView.expandItem(nil, expandChildren: true)
        }
    }
    
}

//NSOutlineViewDataSource Extension.
extension AlternateController2: NSOutlineViewDataSource {
    
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

//Mark: NSOutlineViewDelegate
extension AlternateController2: NSOutlineViewDelegate{
    
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

//MARK: Move to and Independent File:
enum Entities:String{
    case author="Author"
    case language="Language"
    case quote="Quote"
    case tag="Tag"
    case theme="Theme"
    case library="LibraryItem"
    case collection="QuoteList"
}

enum LibraryType:String{
    case tag="tagImage"
    case folder="folderImage"
    case language="languageImage"
    case smartList="smartListImage"
    case list="listImage"
    case favorites="favoritesImage"
    case mainLibrary="mainLibraryImage"
    case rootItem="noImage"
}

