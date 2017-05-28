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
        
        //Set up left panel
//        self.leftOutlineView.dataSource=self
//        self.leftOutlineView.delegate = self

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
                print(currItem)
                
                //Create ManagedObjects
                let theAuthor = Author(context: managedContext)
                let theQuote = Quote(context: managedContext)
                let theThemes = Theme(context: managedContext)
                let theTags = Tags(context: managedContext)
                
                //Configure the items
                theAuthor.name = currItem.value(forKey: "Author") as? String
                theQuote.quote = currItem.value(forKey: "Quote") as? String
                theQuote.isFavorite = randomBool.randomElement() as! Bool
                theThemes.topic = currItem.value(forKey: "Topics") as? String
                theTags.tag = randomTags.randomElement()
                //theQuote.isAbout = NSSet(object: theThemes)
                theQuote.fromAuthor = theAuthor
                theQuote.isFavorite = false
                theQuote.isAbout = theThemes
                theQuote.tags = NSSet(object: theTags)
                
                //Save - Check if tihs is resource-heavy
                //save
                do {
                    print("The quote is: \(String(describing: theQuote.quote))")
                    try managedContext.save()
                    dismiss(self)
                }catch{
                    print("Unable to save the data")
                }
            }
            
        }catch{
            print("Error while parsing JSON: Handle it")
        }
        
    }
    

    //MARK: - Variables
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
    fileprivate lazy var randomTags: [String] = ["Favorite", "Top 25", "Inspirational"] //To erase...for testing
    fileprivate lazy var randomBool: [NSNumber] = [true, false] // To erase....
    
    
    var mainItems: [NSString] = ["Quotes", "Fancy", "Authors", "Themes", "Big View"]
    var secondaryItems: [NSString] = ["Top 5", "Weird", "Long", "Short", "Inspirational", "In english", "In spanish", "From Physicist", "From Actors"]
    fileprivate lazy var leftSideItems: Dictionary<String, [String]> = ["Libraries": ["Quotes", "Fancy", "Authors", "Themes", "Big View"],  "Collections": [ "Top 5", "Weird", "Long", "Short", "Inspirational", "In english", "In spanish", "From Physicist", "From Actors"]]

    //Outlets
    @IBOutlet weak var leftOutlineView: NSOutlineView!
    
    
    
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
            
        }catch{
            print("Could not print the records")
        }
    }
}

// MARK: - Extensions

extension ViewController: NSOutlineViewDelegate {
    
    //provide the data object
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return "Test Data"
    }
    
    //Configure Cells
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let currView = leftOutlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
        currView?.textField?.stringValue = "test 3"
        return currView
    }
}

extension ViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 2 //leftSideItems.count
        }
        else{
            
            return 4 //leftSideItems[item as! String]!.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return "test Child"
    }
    
    


    
}

extension Array {
    
    //Random function to array
    func randomElement() -> Element  {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

