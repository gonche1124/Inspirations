//
//  GroupedController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/3/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class GroupedController: NSViewController {
    
    //MARK: VARIABLES
    //Variables
    fileprivate lazy var frcAuthors = self.setUpFetchedResultsController(typeOfGrouping: "fromAuthor.name")
    fileprivate lazy var frcTopics = self.setUpFetchedResultsController(typeOfGrouping: "isAbout.topic")
    
    //IBOutlets
    @IBOutlet weak var groupedTable: NSOutlineView!

    //"fromAuthor.name"
    var typeOfGrouping: String = "" {
        didSet{
            self.view.displayIfNeeded()
            
            print(self.typeOfGrouping)
        }
    }//This is set through Interface Builder
    
    //Check if this method is still valid.
//    @IBAction func changeSource(_ sender: Any) {
//        if (self.typeOfGrouping=="fromAuthor.name"){
//            self.typeOfGrouping="isAbout.topic"
//            groupedTable.reloadData()
//            groupedTable.expandItem(nil, expandChildren: true)
//        }
//        else {
//            self.typeOfGrouping="fromAuthor.name"
//            groupedTable.reloadData()
//            groupedTable.expandItem(nil, expandChildren: true)
//            
//        }
//    }
    
    //MARK: METHODS
    
    //Setups after the view has load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Populate the NSFetched Controller
        try! frcAuthors.performFetch()
        try! frcTopics.performFetch()
        
        //Table SetUp
        groupedTable.delegate = self
        groupedTable.dataSource = self
        self.reloadDataAndExpand()
        
    }
    
    //Neccesary to voeride in order for the search to work.
    override func viewWillAppear() {
        super.viewWillAppear()
        (self.parent as! ViewController).searchQuote2.delegate=self
        (self.parent as! ViewController).searchQuote.delegate = self
    }
    
    
    //Checks to see if an item is a header
    func isHeader(itemToTest: Any)->Bool {
        return itemToTest is Quote ? false:true
    }
 
    //Initiates a fetchedResultController and returns it
    func setUpFetchedResultsController(typeOfGrouping: String)->NSFetchedResultsController<NSFetchRequestResult> {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: typeOfGrouping, ascending: false)]
        let moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
        let frcTemp = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: typeOfGrouping, cacheName: nil)
        frcTemp.delegate = self
        
        return frcTemp
    }
    
    //Reloeds the data and expands teh view
    func reloadDataAndExpand(){
        self.groupedTable.reloadData()
        self.groupedTable.expandItem(nil, expandChildren:true)
    }
    
}

// MARK: - TableView Extensions

//FetchedResultsControllerDelegate
extension GroupedController: NSFetchedResultsControllerDelegate{
    
    //MAke SURE THE NUMBER OF ROWS GETS UPDATED ACCORDINGLY
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        groupedTable.beginUpdates()
        print("controllerWillChangeContent")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        groupedTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch (type){
        case .insert:
            if let indexPath = newIndexPath {
                groupedTable.reloadData()
                print (indexPath)
            }
        default:break;
        }
    }
}



//NSOutlineViewDataSource
//MARK: NSOutlineViewDataSource
extension GroupedController:NSOutlineViewDataSource{
    
    //Suggested Methods to implement
    // outlineView:child:ofItem: and outlineView:objectValueForTableColumn:byItem:
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if (item is Quote){
            if self.typeOfGrouping == "isAbout.topic" {
                let resultingView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DATACELLWITHAUTHOR"), owner: self) as!NSTableCellView
                (resultingView.viewWithTag(1) as! NSTextField).stringValue = (item as! Quote).quote!
                (resultingView.viewWithTag(2) as! NSTextField).stringValue = ((item as! Quote).fromAuthor?.name)!
                return resultingView
            }
            else {
                let resultingView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DATACELL"), owner: self) as!NSTableCellView
                (resultingView.viewWithTag(1) as! NSTextField).stringValue = (item as! Quote).quote!
                if  ((resultingView.viewWithTag(2)) != nil) {
                    (resultingView.viewWithTag(2) as! NSTextField).stringValue = ((item as! Quote).fromAuthor?.name)!
                }
                return resultingView
            }
        }
        else{
            let resultingView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HEADERCELL"), owner: self) as!NSTableCellView
            resultingView.textField?.stringValue=(item as AnyObject).name!!
            return resultingView
        }
        
    }
    
    //check
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        //Count the number of objects
        if (item == nil) {
            return (self.typeOfGrouping == "fromAuthor.name") ? frcAuthors.sections!.count : frcTopics.sections!.count
            //return frc.sections!.count
        }
        else{
            return (item as! NSFetchedResultsSectionInfo).numberOfObjects
        }
    }
    
    //Check if an item is a header and let it be expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return  self.isHeader(itemToTest:item)// ? true: false
    }
    
    //Returns the child for the specific item at a specific index
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return (self.typeOfGrouping=="fromAuthor.name") ? (frcAuthors.sections!)[index] : (frcTopics.sections!)[index]
        }
        else {
            return (item as! NSFetchedResultsSectionInfo).objects![index]
        }
    }
    
}

//NSoutlineViewDelegate
//MARK: NSOutlineViewDelegate
extension GroupedController:NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        //print ("Delegate item is: \(String(describing: item))")
        return "test YYY"
    }
    
    //Determine if row is group item
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return self.isHeader(itemToTest:item)
    }
    
    //Calculate the height of the rows
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if (self.isHeader(itemToTest: item))
        {
            return 25
        }
        else {
            
            let maxWidth = (outlineView.tableColumns.first?.width)!-18*2
            let constraint = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
            //Get size of quote
            let quoteText = (item as! Quote).quote! as NSString
            let attributesDict = [NSAttributedStringKey.font: NSFont.init(name: "Optima", size: 16.0)!]
            let virtualLText = quoteText.boundingRect(with: constraint,
                                                       options: [NSString.DrawingOptions.usesLineFragmentOrigin, NSString.DrawingOptions.usesFontLeading],
                                                       attributes: attributesDict)
            //Get size of author if applicable
            let authorString = (self.typeOfGrouping=="isAbout.topic") ? CGFloat(24+8) : CGFloat(0)

            return virtualLText.height + authorString + 20*2
        }
    }
    
    //Recalculate height when screen moves
    func outlineViewColumnDidResize(_ notification: Notification) {
        
        let AllIndex = IndexSet(integersIn:0..<self.groupedTable.numberOfRows)
        self.groupedTable.noteHeightOfRows(withIndexesChanged: AllIndex)
    }
}


//MARK: NSSearchFieldDelegate
extension GroupedController: NSSearchFieldDelegate{
    
    //Called when the users finishes searching.
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.frcAuthors.fetchRequest.predicate = nil
        try! self.frcAuthors.performFetch()
        self.reloadDataAndExpand()
    }
    
    //Calls everytime a user inputs a character.
    override func controlTextDidChange(_ obj: Notification) {
        let searchString = (obj.object as? NSSearchField)!.stringValue
        if searchString == "" {
            return
        }
        let tempPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@",searchString)
        self.frcAuthors.fetchRequest.predicate = tempPredicate
        try! self.frcAuthors.performFetch()
        self.reloadDataAndExpand()
        (self.parent as? ViewController)?.informationLabel.stringValue = "Showing \(self.frcAuthors.fetchedObjects!.count) of 33 records"

        //Check out predicateWithSubstitutionVariables method to simplify code.
    }
    
    
}

