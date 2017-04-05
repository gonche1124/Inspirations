//
//  PlainTable.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/5/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


class PlainTable: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Table SetUp
        quotesTable.delegate = self
        quotesTable.dataSource = self
        
        //Populate the NSFetched Controller
        do{
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
    }
    
    
    // MARK: - TableView Methods
    @IBOutlet weak var quotesTable: NSTableView!
    
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController <NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fromAuthor.firstName", ascending: false)]
        let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
        
    }()
    
    
    
    
}

// MARK: - TableView Extensions

//FetchedResultsControllerDelegate
extension PlainTable: NSFetchedResultsControllerDelegate{
    
    //MAke SURE THE NUMBER OF ROWS GETS UPDATED ACCORDINGLY
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        quotesTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        quotesTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type){
        case .insert:
            if let indexPath = newIndexPath {
                quotesTable.reloadData()
            }
        default:break;
        }
    }
}

//TableViewDataSource
extension PlainTable: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let quotesData = fetchedResultsController.fetchedObjects else {return 0}
        return quotesData.count
    }
    
}

// TableViewDelegate
extension PlainTable: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let indexPath = IndexPath(item: row, section: 0)
        guard let currQuote = fetchedResultsController.object(at: indexPath) as? Quote
            else {fatalError("Unexpected Object in FetchedResultsController")}
        
        if tableColumn!.title == "Quote" {
            return currQuote.quote
        }
        else if tableColumn!.title == "Author" {
            return currQuote.fromAuthor?.firstName
        }
        else if tableColumn!.title == "Theme" {
            return (currQuote.isAbout?.allObjects.first as! Theme).topic
        }
        else if tableColumn!.title == "Favorite"{
            
            if currQuote.isFavorite { return #imageLiteral(resourceName: "red heart")} else { return #imageLiteral(resourceName: "grey heart")}
        }
        return ""
    }
}
