//
//  ViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa
import Foundation


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
        do {
            try fetchedResultsControler.performFetch()
            print ("The items are: \(fetchedResultsControler.fetchedObjects?.count)")
            
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
    
    //MARK: - Import methods
    @IBAction func importData(_ sender: NSButton) {
        
        let dialog = NSOpenPanel()
        dialog.title = "Choose a JSON file"
        dialog.showsResizeIndicator = true
        dialog.allowedFileTypes = ["json"]
        
        if (dialog.runModal() == NSModalResponseOK) {
            importFromJSON(pathToFile: dialog.url!)
        }
        else{
            print("Cancel")
            return
        }
        
    }
    
    func importFromJSON(pathToFile: URL ){
        
        //Read into Array
        let jsonData = NSData(contentsOf: pathToFile)
        do{
            let jsonArray = try JSONSerialization.jsonObject(with: (jsonData)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray
            
            
            //Iterate over evey item adding a NSMAnagedObject
            for jsonItem in jsonArray {
                
                let currItem = jsonItem as! NSDictionary
                
                //Create ManagedObjects
                let theAuthor = Author(context: managedContext)
                let theQuote = Quote(context: managedContext)
                let theThemes = Theme(context: managedContext)
                
                //Configure the items
                theAuthor.firstName = currItem.value(forKey: "Author") as? String
                theQuote.quote = currItem.value(forKey: "Quote") as? String
                theThemes.topic = currItem.value(forKey: "Topics") as? String
                theQuote.isAbout = NSSet(object: theThemes)
                theQuote.fromAuthor = theAuthor
                theQuote.isFavorite = false
                
                //Save - Check if tihs is resource-heavy
                //save
                do {
                    try managedContext.save()
                    dismiss(self)
                }catch{
                    print("Unable to save the data")
                }
            }
            
            
            print(jsonArray)
        }catch{
            print("Error while parsing JSON: Handle it")
        }
        
    }
    
    
    
    
    
    
    
    // MARK: - TableView Methods
    @IBOutlet weak var quotesTable: NSTableView!
    
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
    
    
    // MARK: - Helpers
    
    //Function to print the number of elemtns in core data
    func printCurrentData(){
        
        //get context
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Retrieve the current Data.
        var listQuotes = [Quote]()//[NSManagedObject]()
        do{
            let records = try managedContext.fetch(quotesRequest)
            if let records = records as? [Quote]{
                listQuotes=records
            }
            print("number of records is: \(listQuotes.count)")
            print ("An Author is: \(listQuotes.first?.fromAuthor?.firstName)")
   
            
        }catch{
            print("Could not print the records")
        }
    }
}

// MARK: - TableView extensions
extension ViewController: NSFetchedResultsControllerDelegate{
    
    //MAKE SURE THE NUMBER OF ROWS GETS UPDATED ACCORDINGLY
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
                //quotesTable.insertRows(at: [indexPath], withAnimation: .effectGap)
                
            }
        default:break;

        }
    }
    
}



extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let quotesData =  fetchedResultsControler.fetchedObjects else {return 0}
        return quotesData.count
    }
    
}


extension ViewController: NSTableViewDelegate {
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let indexPath = IndexPath(item: row, section: 0)
        guard let currQuote = fetchedResultsControler.object(at: indexPath) as? Quote else {fatalError("Unexpected Object in FetchedResultsController")}
        
        
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

