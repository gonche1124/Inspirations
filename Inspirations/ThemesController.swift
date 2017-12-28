//
//  TagsController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/11/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


class ThemesController: NSViewController {
    
    //MARK: VARIABLES
    //Variables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
   
    //IBOutlets
    @IBOutlet weak var tagsOultineView: NSOutlineView!
    @IBOutlet var themeController: NSTreeController!
    
    //MARK: METHODS
    //Setups after the view has load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Table SetUp
        themeController.sortDescriptors = [NSSortDescriptor(key:"sortingKey", ascending:true)]

    }
    
    //Neccesary to voeride in order for the search to work.
    override func viewWillAppear() {
        super.viewWillAppear()
        (self.parent as! ViewController).searchQuote2.delegate=self
    }
}

//MARK: - NSOutlineViewDataSource
extension ThemesController:NSOutlineViewDataSource{
    
    //Check if item is expandable. Mandatory
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as! NSTreeNode).isTheme()
    }
    

    // WWDC 2016 method.
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let sQuote = (item as? NSTreeNode)!.representedObject as? Quote else {return nil}
        let thisItem = NSPasteboardItem()
        thisItem.setString(sQuote.objectID.uriRepresentation().absoluteString, forType: .string)
        return thisItem
    }
}

//MARK: NSOutlineViewDelegate
extension ThemesController:NSOutlineViewDelegate{
    
    //Returns View for Row.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        let typeOfCell: String = (!(item as! NSTreeNode).isTheme()) ? "DataCell": "HeaderCell"
        return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
    }
    
    //Identify group rows to float.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (item as! NSTreeNode).isTheme()
    }
}


//MARK: NSSearchFieldDelegate
extension ThemesController: NSSearchFieldDelegate{
    
    //Called when the users finishes searching.
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        themeController.fetchPredicate = nil
        try! themeController.fetch(with: nil, merge: false)
        //tagsOultineView.reloadData()
        //tagsOultineView.expandItem(nil, expandChildren: true)
        tagsOultineView.expandItem(nil, expandChildren: true)
    }
    
    //Calls everytime a user inputs a character.
    override func controlTextDidChange(_ obj: Notification) {
        print ("Themes Delegate called")
        let searchString = (obj.object as? NSSearchField)!.stringValue
        if searchString == "" {
            return
        }
        let tempPredicate = NSPredicate(format: "topic CONTAINS[cd] %@",searchString)
        themeController.fetchPredicate = tempPredicate
        try! themeController.fetch(with: nil, merge: false)
        //tagsOultineView.reloadData()
        //tagsOultineView.expandItem(nil, expandChildren: true)
        //(self.parent as? ViewController)?.informationLabel.stringValue = "Showing \(self.frcAuthors.fetchedObjects!.count) of 33 records"
        
        //Check out predicateWithSubstitutionVariables method to simplify code.
    }
}




