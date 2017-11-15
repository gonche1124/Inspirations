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
        tagsOultineView.expandItem(nil, expandChildren: true)
        
        //Set up search field.
        (self.parent as? ViewController)?.searchQuote2.delegate = self
        
        
    }
    
    //Awake from NIB to prefetch controllers.
    override func awakeFromNib() {
        super.awakeFromNib()
        try! themeController.fetch(with: nil, merge: false)
    }
    
    //Neccesary to voeride in order for the search to work.
    override func viewWillAppear() {
        super.viewWillAppear()
        //(self.parent as! ViewController).searchQuote2.delegate=self
    }
    
    //Reloeds the data and expands teh view
    func reloadDataAndExpand(){
        self.tagsOultineView.reloadData()
        self.tagsOultineView.expandItem(nil, expandChildren:true)
    }
    
}

//MARK: - NSOutlineViewDataSource
extension ThemesController:NSOutlineViewDataSource{
    
    //Sets teh object associated witha  row. Mandatory?
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return (item as! NSTreeNode).representedObject
    }
    
    //Gets number of children. Mandatory
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        guard let currItem = item as? NSTreeNode else {
            return (themeController.arrangedObjects.children?.count)!
        }
        return (currItem.isTheme()) ? (currItem.children?.count)! : 0
    }
    
    //Gets the child. Mandatory
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let nodeItem = item as? NSTreeNode else {
            return themeController.arrangedObjects.children![index]
        }
        return nodeItem.children![index]
    }
    
    //Check if item is expandable. Mandatory
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as! NSTreeNode).isTheme()
    }

}

//NSoutlineViewDelegate
//MARK: NSOutlineViewDelegate
extension ThemesController:NSOutlineViewDelegate{
    
    //Draws the cell-view.
    func configureViewForItem(_ typeOfCell: String, _ item: Any, _ currView: NSTableCellView?) -> NSTableCellView? {
        //Set up view
        if typeOfCell == "HeaderCell" {
            let currItem = (item as! NSTreeNode).representedObject as! Theme
            currView?.textField?.stringValue = (currItem.topic!.uppercased())
        }else{
            guard let currItem = (item as! NSTreeNode).representedObject as? Quote else {
                currView?.textField?.stringValue = "Didnt work"
                return currView
            }
            (currView?.viewWithTag(1) as! NSTextField).stringValue = currItem.quote!
            (currView?.viewWithTag(2) as! NSTextField).stringValue = (currItem.fromAuthor?.name!)!
            
        }
        return currView
    }
    
    //Returns View for Row.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        let typeOfCell: String = (!(item as! NSTreeNode).isTheme()) ? "DataCell": "HeaderCell"
        var currView = tagsOultineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
        if let currViewParam = currView {
            currView = configureViewForItem(typeOfCell, item, currViewParam)
        }
    
        return currView
    }
    
    //Method 2 of trying to setup height.
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {

        let typeOfCell: String = (!(item as! NSTreeNode).isTheme()) ? "DataCell": "HeaderCell"
        var currView = tagsOultineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
        if let currViewParam = currView {
            currView = configureViewForItem(typeOfCell, item, currViewParam)
            currView?.layoutSubtreeIfNeeded()
        }
        return (currView?.frame.height)!
    }
    
    //Identify group rows to float.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (item as! NSTreeNode).isTheme()
    }
    
    //Recalculate height when screen moves
    func outlineViewColumnDidResize(_ notification: Notification) {
        let AllIndex = IndexSet(integersIn:0..<self.tagsOultineView.numberOfRows)
        self.tagsOultineView.noteHeightOfRows(withIndexesChanged: AllIndex)
    }
}


//MARK: NSSearchFieldDelegate
extension ThemesController: NSSearchFieldDelegate{
    
    //Called when the users finishes searching.
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        themeController.fetchPredicate = nil
        self.reloadDataAndExpand()
    }
    
    //Calls everytime a user inputs a character.
    override func controlTextDidChange(_ obj: Notification) {
        print ("Themes Delegate called")
        let searchString = (obj.object as? NSSearchField)!.stringValue
        if searchString == "" {
            return
        }
        let tempPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@",searchString)
        themeController.fetchPredicate = tempPredicate
        self.reloadDataAndExpand()
        //(self.parent as? ViewController)?.informationLabel.stringValue = "Showing \(self.frcAuthors.fetchedObjects!.count) of 33 records"
        
        //Check out predicateWithSubstitutionVariables method to simplify code.
    }
}




