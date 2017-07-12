//
//  GroupedController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/3/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class GroupedController: NSViewController {
    
    var typeOfGrouping: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
     
        
        //Populate the NSFetched Controller
        do{
            try frc.performFetch()
            print ("Total Items: \(String(describing: frc.fetchedObjects?.count))")
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        //Table SetUp
        groupedTable.reloadData()
        groupedTable.delegate = self
        groupedTable.dataSource = self
        groupedTable.reloadData()
        
        //Setup Outlineview
        groupedTable.expandItem(nil, expandChildren: true)
        
        //Debugging
        print("number of section is: \(String(describing: frc.sections?.count))")
        
        //let s = frc.sections as! [NSFetchedResultsSectionInfo]
        //for item in s{
            //print("Number of items for section is: \(item.numberOfObjects) and the name is: \(item.name) and the indexTitle is: \(item.indexTitle)")
        //}
        
    }
    
    //IBOutlets
    @IBOutlet weak var groupedTable: NSOutlineView!
   
    
    //Variables
    fileprivate lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")

    
    fileprivate lazy var frc: NSFetchedResultsController <NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fromAuthor.name", ascending: false)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: self.typeOfGrouping, ascending: false)]

        //fetchRequest.sortDescriptors = [NSSortDescriptor(key:"isAbout.topic", ascending:false)]
        let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        //let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "fromAuthor.name", cacheName: nil)
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: self.typeOfGrouping, cacheName: nil)
        //let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "isAbout.topic", cacheName: nil)
        frc.delegate = self
        
        
        
        return frc
        
    }()
    
    
    //Checks to see if an item is a header
    func isHeader(itemToTest: Any)->Bool {
        //Make it more globally... is = "isKindfOfClass"
        
        var flagLocal:Bool
        
        if (itemToTest is Quote) {
            flagLocal=false
        }
        else{
            flagLocal=true
        }
        //let flagLocal = (itemToTest is Quote)
        

        return (flagLocal)
    }
}

// MARK: - TableView Extensions


//FetchedResultsControllerDelegate
extension GroupedController: NSFetchedResultsControllerDelegate{
    
    //MAke SURE THE NUMBER OF ROWS GETS UPDATED ACCORDINGLY
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        groupedTable.beginUpdates()
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
            let resultingView = outlineView.make(withIdentifier: "DATACELL", owner: self) as!NSTableCellView
            (resultingView.viewWithTag(1) as! NSTextField).stringValue = (item as! Quote).quote!
            if  ((resultingView.viewWithTag(2)) != nil) {
                (resultingView.viewWithTag(2) as! NSTextField).stringValue = ((item as! Quote).fromAuthor?.name)!
            }
            //resultingView.textField?.stringValue=(item as! Quote).quote!
            return resultingView
        }
        else{
            let resultingView = outlineView.make(withIdentifier: "HEADERCELL", owner: self) as!NSTableCellView
            resultingView.textField?.stringValue=(item as AnyObject).name as! String
            return resultingView
        }
        
    }
    
    //check
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        //NOt sure if this works
        if (item == nil) {
            let s = frc.sections!
            return s.count
        }
        else{
            //print ("numberOfChildren for item \(String(describing: item))")
            return (item as! NSFetchedResultsSectionInfo).numberOfObjects
        }
    }
    
    //Check if an item is a header and let it be expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return  self.isHeader(itemToTest:item)// ? true: false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            //let s = frc.sections as! [NSFetchedResultsSectionInfo]
            return (frc.sections!)[index]
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
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return self.isHeader(itemToTest:item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if (self.isHeader(itemToTest: item))
        {
            return 25
        }
        else {
            return 48
        }
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
