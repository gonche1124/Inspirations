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
        leftOutlineView.expandItem(nil, expandChildren: true)

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            //leftOutlineView.reloadData()
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
                let theAuthor = findOrCreateObject(authorName: currItem.value(forKey: "Author") as! String) as! Author
                let theQuote = Quote(context: managedContext)
                let theThemes = Theme(context: managedContext)
                let theTags = Tags(context: managedContext)
                
                //Configure the items
                //theAuthor.name = currItem.value(forKey: "Author") as? String
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
    
    var topLevelItems : [String] = ["Views", "Curated", "Collections"]
    var mainItems: [String] = ["Quotes", "Fancy", "Authors", "Themes", "Big View"]
    var curatedItems: [String] = ["Top 5", "Weird","From Physicist", "From Actors"]
    var secondaryItems: [String] = [ "Long", "Short", "Inspirational", "In english", "In spanish"]
    
    fileprivate lazy var leftSideItems : Dictionary<String, Array<String>> = ["Views": ["Quotes", "Fancy", "Authors", "Themes", "Big View"], "Curated": ["Top 5", "Weird","From Physicist", "From Actors"], "Collections": [ "Long", "Short", "Inspirational", "In english", "In spanish"]]

    //Outlets
    @IBOutlet weak var leftOutlineView: NSOutlineView!
    @IBOutlet weak var containerView: NSView!
    
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
    
    func findOrCreateObject(authorName: String)->NSManagedObject {
        
        //Find object
        let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let authorFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Author")
        let authorPredicate = NSPredicate(format: "name == %@", authorName)
        authorFetch.predicate = authorPredicate
        
        //Execute fetch
        do {
            let existingAuthor = try moc.fetch(authorFetch) as! [Author]
            
            if existingAuthor.count > 0 {
                return existingAuthor.first!
            }
            else {
                let returnedAuthor = Author(context: moc)
                returnedAuthor.name = authorName
                return returnedAuthor
            }
            
        }
        catch {
            fatalError(error as! String)
        }
    }
}

// MARK: - Extensions

extension ViewController: NSOutlineViewDelegate {
    
    //Configure Cells
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        //Check if it is root item
        if topLevelItems.contains(item as! String){
            let currView = leftOutlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            currView?.textField?.stringValue = (item as! String).uppercased()
            return currView
        }
        else {
            let currView = leftOutlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
            currView?.textField?.stringValue = item as! String
            if (item as! String == "Quotes") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameUserGuest)}
            if (item as! String == "Fancy") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameBonjour)}
            if (item as! String == "Authors") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameHomeTemplate)}
            if (item as! String == "Themes") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameInfo)}
            if (item as! String == "Big View") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameNetwork)}
            
            return currView
        }
    }
    
    //Selection changed
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedItem = leftOutlineView.selectedRow
        if ((selectedItem == 1) || (selectedItem == 3) || (selectedItem == 2)) {
            let tabController = self.childViewControllers[0] as! NSTabViewController
            tabController.selectedTabViewItemIndex = selectedItem-1
        }
    }
    
}

extension ViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
       //Check if it is root item
        return item == nil ? topLevelItems.count : (leftSideItems[item as! String]?.count)!
    }
    
    //Formats group cells
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return topLevelItems.contains(item as! String)
    }
    
    //Wheather each item is expandable or not
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return topLevelItems.contains(item as! String) ? true:false
    }
    
    //Return the item depending ong the herarchy level
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return topLevelItems[index]
        }
        else {
            return leftSideItems[item as! String]?[index] ?? ""
        }
    }
    
    
    
}

extension Array {
    
    //Random function to array
    func randomElement() -> Element  {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

