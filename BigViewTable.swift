//
//  BigViewTable.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/5/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class BigViewCell: NSTableCellView{
    
    @IBOutlet weak var authorLabel: NSTextField!
    @IBOutlet weak var quoteLabel: NSTextField!

}



class BigViewTable: NSViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Fetch
        //Populate the NSFetched Controller
                do {
                    try fetchedResultsControler.performFetch()
                    //print ("The items are: \(fetchedResultsControler.fetchedObjects?.count)")
        
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
        
        //Table setup
        bigTable.delegate = self
        bigTable.dataSource = self
    }
    
    
    @IBOutlet weak var bigTable: NSTableView!
    
    
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
    fileprivate lazy var fetchedResultsControler: NSFetchedResultsController<NSFetchRequestResult> = {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fromAuthor.firstName", ascending: false)]
                let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
                let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
                frc.delegate = self
                return frc
            }()
    
    
    
    
}

// MARK: - Extensions

extension BigViewTable: NSTableViewDelegate{
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        print ("TableViewCalled2")
        
        if let cell = tableView.make(withIdentifier: "singleCellView", owner: nil) as? BigViewCell {
            cell.authorLabel.stringValue = "Test 12"
            cell.quoteLabel.stringValue = "Test22"
            print ("cell returned2")
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        //Template
        let cellView = tableView.make(withIdentifier: "singleCellView", owner: nil) as? BigViewCell
        let currQuote = fetchedResultsControler.object(at: IndexPath(item: row, section: 0)) as? Quote
        cellView?.authorLabel.stringValue = (currQuote?.fromAuthor?.firstName)!
        cellView?.quoteLabel.stringValue = (currQuote?.quote)!
        cellView?.bounds.size.width = tableView.bounds.size.height
        cellView!.layoutSubtreeIfNeeded()
        let height = cellView?.fittingSize.height
        print ("height is: \(String(describing: height))")
   
 //       return height! > tableView.rowHeight ? height! : tableView.rowHeight
        return 140
    }
    
    //Change height of rows when column size changes
    func tableViewColumnDidResize(_ notification: Notification) {
        let allIndexes = IndexSet(integersIn: 0..<bigTable.numberOfRows)
        bigTable.noteHeightOfRows(withIndexesChanged: allIndexes)
    }
}

extension BigViewTable: NSTableViewDataSource{
    
    //Total Rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 20 //NOt time consuming
        //return (fetchedResultsControler.fetchedObjects?.count)!
    }
    
    //Create View
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.make(withIdentifier: "singleCellView", owner: nil) as? BigViewCell {
            
            let currQuote = fetchedResultsControler.object(at: IndexPath(item: row, section: 0)) as! Quote
            print (currQuote)
            cell.authorLabel.stringValue = "- " + (currQuote.fromAuthor?.firstName)!
            cell.quoteLabel.stringValue =  "\"" + (currQuote.quote)! + "\""
            return cell
        }
        return nil
    }
}

extension BigViewTable: NSFetchedResultsControllerDelegate{
    
}

