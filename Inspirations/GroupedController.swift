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
    @IBAction func changeSource(_ sender: Any) {
        if (self.typeOfGrouping=="fromAuthor.name"){
            self.typeOfGrouping="isAbout.topic"
            groupedTable.reloadData()
            groupedTable.expandItem(nil, expandChildren: true)
        }
        else {
            self.typeOfGrouping="fromAuthor.name"
            groupedTable.reloadData()
            groupedTable.expandItem(nil, expandChildren: true)
            
        }
    }
    
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
        let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
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
extension GroupedController:NSOutlineViewDataSource{
    
    //Suggested Methods to implement
    // outlineView:child:ofItem: and outlineView:objectValueForTableColumn:byItem:
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if (item is Quote){
            if self.typeOfGrouping == "isAbout.topic" {
                let resultingView = outlineView.make(withIdentifier: "DATACELLWITHAUTHOR", owner: self) as!NSTableCellView
                (resultingView.viewWithTag(1) as! NSTextField).stringValue = (item as! Quote).quote!
                (resultingView.viewWithTag(2) as! NSTextField).stringValue = ((item as! Quote).fromAuthor?.name)!
                return resultingView
            }
            else {
                let resultingView = outlineView.make(withIdentifier: "DATACELL", owner: self) as!NSTableCellView
                (resultingView.viewWithTag(1) as! NSTextField).stringValue = (item as! Quote).quote!
                if  ((resultingView.viewWithTag(2)) != nil) {
                    (resultingView.viewWithTag(2) as! NSTextField).stringValue = ((item as! Quote).fromAuthor?.name)!
                }
                return resultingView
            }
        }
        else{
            let resultingView = outlineView.make(withIdentifier: "HEADERCELL", owner: self) as!NSTableCellView
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
            let attributesDict = [NSFontAttributeName: NSFont.init(name: "Optima", size: 16.0)!]
            let virtualLText = quoteText.boundingRect(with: constraint,
                                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
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

//Extension fro search field
extension GroupedController: NSSearchFieldDelegate{
    
    //Called when user starts searching.
//    func searchFieldDidStartSearching(_ sender: NSSearchField) {
//        print("Searchfield did start searching \(sender.stringValue)")
//    }
    //Called when the users finishes searching.
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.frcAuthors.fetchRequest.predicate = nil
        try! self.frcAuthors.performFetch()
        self.reloadDataAndExpand()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let searchString = (obj.object as? NSSearchField)!.stringValue
        if searchString == "" {
            return
        }
        //let tempFetchReq = self.frcAuthors.fetchRequest
        let tempPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@",searchString)
        self.frcAuthors.fetchRequest.predicate = tempPredicate
        try! self.frcAuthors.performFetch()
        self.reloadDataAndExpand()
        (self.parent as? ViewController)?.informationLabel.stringValue = "Showing \(self.frcAuthors.fetchedObjects!.count) of 33 records"

        //Check out predicateWithSubstitutionVariables method to simplify code.
    }
    
    
}

/*
//TableViewDataSource
extension GroupedController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let quotesData = frc.fetchedObjects else {return 0}
        print ("total items in this section is: \(quotesData.count)")
        return quotesData.count
    }
    
  
    
    
}

// TableViewDelegate
extension GroupedController: NSTableViewDelegate {
    
    //TEST
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return row % 4 == 0 ? true: false
    }
    
    
    //View Based method
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        print ("The table column identifier is: \(tableColumn?.identifier) and the row number is \(row)")
        //print (type(of:frc.object(at: row)))
        
        
        var resultingView: NSTableCellView
        resultingView = tableView.make(withIdentifier: "dataRow", owner: self) as! NSTableCellView
        //resultingView = tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        resultingView.textField?.stringValue="test quote"//((frc.object(at: IndexPath(item: row, section: 0)) as? Quote)?.quote)!
        
        
        
        
        
        return resultingView
    }
    
    /*func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let indexPath = IndexPath(item: row, section: 0)
        guard let currQuote = frc.object(at: indexPath) as? Quote
            else {fatalError("Unexpected Object in FetchedResultsController")}
        
        print("\(tableColumn!.identifier)")
        if tableColumn!.identifier == "quoteColumn" {
            print ("TableView called and identifier is quoteColumn")

            return currQuote.quote
        }
        //        else if tableColumn!.title == "Author" {
        //            return currQuote.fromAuthor?.firstName
        //        }
        //        else if tableColumn!.title == "Theme" {
        //            return (currQuote.isAbout?.allObjects.first as! Theme).topic
        //        }
        //        else if tableColumn!.title == "Favorite"{
        //
        //            if currQuote.isFavorite { return #imageLiteral(resourceName: "red heart")} else { return #imageLiteral(resourceName: "grey heart")}
        //        }
        return ""
    } */
    
  
}
 */
