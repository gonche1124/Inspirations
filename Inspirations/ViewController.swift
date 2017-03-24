//
//  ViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

//comments to delete
class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        printCurrentData()
        
        //Tableview setup
        quotesTable.delegate=self
        quotesTable.dataSource=self
        
        //Populate the NSFetched Controller
        //MAKE SURE THIS GETS CALLED FIRST!!!!!!!!!
        do {
            try fetchedResultsControler.performFetch()
            print ("The items are: \(fetchedResultsControler.fetchedObjects?.count)")
            print ("fecthed results")
            
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
      
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - TableView Methods
    @IBOutlet weak var quotesTable: NSTableView!
    
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")

    
    fileprivate lazy var fetchedResultsControler: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: true)]
        //fetchRequest.predicate = NSPredicate(format: "user.id = %@", self.friend!.id!)
        let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    // MARK: - Helpers
    
    //Function to print the number of elemtns in core data
    func printCurrentData(){
        
        //get context
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Retrieve the current Data.
        var listQuotes = [NSManagedObject]()
        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
        do{
            let records = try managedContext.fetch(quotesRequest)
            if let records = records as? [NSManagedObject]{
                listQuotes=records
            }
            print("number of records is: \(listQuotes.count)")
   
            
        }catch{
            print("Could not print the records")
        }
    }
}

//TableView extensions
extension ViewController: NSFetchedResultsControllerDelegate{
    
}



extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print ("The items2 are: \(fetchedResultsControler.fetchedObjects?.count)")
        guard let quotesData =  fetchedResultsControler.fetchedObjects else {return 0}
        
        print ("The emthod is returning : \(quotesData.count)")
        
        return quotesData.count
    }
    
}


extension ViewController: NSTableViewDelegate {
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
            //let textTemp = tableColumn?.title
            //print(" \(textTemp)")
        if tableColumn!.title == "Quote" {
            return "test1"
        }
        else if tableColumn!.title == "Author" {
            return "Andres1"
        }
        return ""
    }
    
}

