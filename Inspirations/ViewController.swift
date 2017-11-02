//
//  ViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        printCurrentData()
        printPlaylistData()
        
        //To comment.
        //addTempDefaultValues()
        
        //Set up left panel
        leftOutlineView.expandItem(nil, expandChildren: true)
        
        
        //Initialize and add the different Views that the App will use. (Check if efficient management of resources).
        VCPlainTable = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "VCPlainTable") as! CocoaBindingsTable
        VCQuoteTable = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "VCQuotesTable") as! QuoteController
        VCBigView = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "VCBigView") as! BigViewController
        VCGroupedMixTable = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "VCGroupedMix") as! GroupedController
        //Add controllers
        self.addChildViewController(VCPlainTable)
        self.addChildViewController(VCQuoteTable)
        self.addChildViewController(VCBigView)
        self.addChildViewController(VCGroupedMixTable)
        //Set default view
        VCBigView.view.frame = self.containerView.bounds
        self.containerView.addSubview(VCBigView.view)

    }
    
    //Selects the view controller to show depending on the button selected.
    @IBAction func changeViewOfQuotes(_ sender: NSSegmentedControl) {
        //Remove all views.
        for cView in self.containerView.subviews {
            cView.removeFromSuperview()
        }
        //Show selected View
        if sender.indexOfSelectedItem == 0 {
            VCPlainTable.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCPlainTable.view)
        }
        else if sender.indexOfSelectedItem == 1 {
            VCQuoteTable.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCQuoteTable.view)
        }
        else if sender.indexOfSelectedItem == 2 {
            VCBigView.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCBigView.view)
    
        }
        else if sender.indexOfSelectedItem == 3 {
            VCGroupedMixTable.view.frame = self.containerView.bounds
            VCGroupedMixTable.typeOfGrouping = "fromAuthor.name"
            VCGroupedMixTable.groupedTable.reloadData()
            VCGroupedMixTable.groupedTable.expandItem(nil, expandChildren: true)
            self.containerView.addSubview(VCGroupedMixTable.view)
        }
        else {
            VCGroupedMixTable.view.frame = self.containerView.bounds
            VCGroupedMixTable.typeOfGrouping = "isAbout.topic"
            VCGroupedMixTable.groupedTable.reloadData()
            VCGroupedMixTable.groupedTable.expandItem(nil, expandChildren: true)
            self.containerView.addSubview(VCGroupedMixTable.view)
        }
        
    }
    //Test.....
    //fileprivate lazy var fileTree = NSArray(contentsOfFile: customPath)
    
    
    /*fileprivate lazy var fileTree2 =
        [["label": "Views", "isGroup": true, "children":
            ["Quotes", "Fancy", "Authors", "Themes", "Big View"]],
        ["label":"Curated", "isGroup": true, "children":
            ["Top 5", "Weird","From Physicist", "From Actors"]],
        ["label":"Collections", "isGroup": true, "children":
            [ "Long", "Short", "Inspirational", "In english", "In spanish"]]]
*/
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            //leftOutlineView.reloadData()
        }
    }
    
    fileprivate lazy var fileTree = NSMutableArray(contentsOfFile: Bundle.main.path(forResource: "treeList", ofType: ".plist")!)
    
    //MARK: - Import methods
    @IBAction func importData(_ sender: NSButton) {
        
        let dialog = NSOpenPanel()
        dialog.title = "Choose a JSON file"
        dialog.showsResizeIndicator = true
        dialog.allowedFileTypes = ["json", "txt"]
        
        //For debugging only
        //let test = URL(fileURLWithPath: "file:///Users/Gonche/Desktop/jsonTest.txt")
        let test = URL.init(string: "file:///Users/Gonche/Desktop/jsonTest.txt")
        importExport().importFromJSONV2(pathToFile: test!)
        
        
        if (dialog.runModal() == NSModalResponseOK) {
            print (dialog.url!)
            importExport().importFromJSONV2(pathToFile: dialog.url!)
            dismiss(self)
            //importFromJSON(pathToFile: dialog.url!)
        }
        else{
            print("Cancel")
            return
        }
        
    }
    
    //Add a list to the tree view and refresh the data.
    @IBAction func addListToTree(_ sender: NSButton) {
        
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "Add list"
        msg.informativeText = "Enter the name of the list you want to add"
        
        //Add text field
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        msg.accessoryView = txt
        
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            addItemToTreeFile(itemToAdd: txt.stringValue)
            print(txt.stringValue)
        } else {
            print("canceled")
        }
   
    
    }
    //Deleted the selected list from the tree controller
    //TO IMPLEMENT
    @IBAction func deleteListFromTree(_ sender: NSButton) {
        
        let alert = NSAlert()
        alert.informativeText = "Are you sure you want to delete de list?"
        alert.messageText = "Delete List"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.runModal()
        
    }


    //MARK: - Export
    
    
    @IBAction func exportCoreModel(_ sender: NSButton) {
        importExport().exportAllTheQuotes()
    }
    
    //MARK: - Variables
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
    fileprivate lazy var randomTags: [String] = ["Favorite", "Top 25", "Inspirational"] //To erase...for testing
    fileprivate lazy var randomBool: [NSNumber] = [true, false] // To erase....
    
    //Controllers of different Views Final
    var VCPlainTable : CocoaBindingsTable!
    var VCQuoteTable : QuoteController!
    var VCBigView : BigViewController!
    var VCGroupedMixTable : GroupedController!
 
    //Outlets
    @IBOutlet weak var leftOutlineView: NSOutlineView!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var searchQuote: NSSearchField!
    
    //@IBOutlet weak var container2View: NSView!
    
    
    // MARK: - Helpers
    func updateInfoLabel(parameter: Any){
        self.informationLabel.stringValue = "Showing \(parameter) of the 33 records"
    }
    
    //Function to add item to tree, refresh and write data.
    func addItemToTreeFile(itemToAdd:String){
        
        //Create dict
        let dictItem = ["label": itemToAdd, "iconName": "NSUser"]
        var collectionDict = fileTree!.lastObject as? [String: Any]
        var collectionItems = collectionDict!["children"] as! NSArray
        collectionItems = collectionItems.adding(dictItem) as NSArray

        //Add to fileTree
        collectionDict?["children"] = collectionItems
        fileTree?.removeLastObject()
        fileTree?.add(collectionDict!)
        
        //reload data and save??
        leftOutlineView.reloadData()
        leftOutlineView.expandItem(nil, expandChildren: true)
        writeCurrentTreeToFile()

    }
    
    //Writes to file
    //TO IMPLEMENT
    func writeCurrentTreeToFile(){
        
       //if let bundlePath = Bundle.main.path(forResource: "treePlist", ofType: "plist") {
        //fileTree?.write(to: URL(String:bundlePath), atomically: true)
        //}
        
    }
    
    //Function that determines whether an object contains a specific key
    func itemCOntainsKey(itemToCheck: Any, keyToCheck: String)->Bool
    {
        var salida = false
        if let salida2 = itemToCheck as? Dictionary<String, Any> {
            salida = salida2.keys.contains("isGroup")
        }
        //print (salida)
        return salida
    }
    
    //To ERASE, only used for adding default values.
    func addTempDefaultValues(){
        //get context
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Adds two main playlists.
        let principal = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: managedContext) as! Playlist
        let folderList = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: managedContext) as! Playlist
        principal.pName = "Library"
        folderList.pName = "Lists"
        principal.isLeaf=false
        folderList.isLeaf=false
        
        //Adds subgroup of main
        let mainList = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: managedContext) as! Playlist
        mainList.pName = "Main"
        mainList.pType = "General"
        mainList.isInPlaylist=principal
        
        let favList = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: managedContext) as! Playlist
        favList.pName = "Favorites"
        favList.pType = "General"
        mainList.isInPlaylist=principal
        favList.isInPlaylist=principal
        
        try! managedContext.save()
        
        for i in 1...10 {
            let tempList = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: managedContext) as! Playlist
            tempList.pName = "random name \(i)"
            tempList.isInPlaylist = folderList
            try! managedContext.save()
        }
    }
    
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
            self.informationLabel.stringValue = "Showing \(listQuotes.count) of \(listQuotes.count)"
            
        }catch{
            print("Could not print the records")
        }
    }
    
    //Function to print playlist data.
    func printPlaylistData(){
        //get context
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Retrieve data.
        let fetchR = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        let lists : [Playlist] = try! managedContext.fetch(fetchR) as! [Playlist]
        print ("number of playlists is: \(lists.count)")
        //print (lists)
        
    }
    
}

// MARK: - Extensions

extension ViewController: NSOutlineViewDelegate {
    
    //Configure Cells
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        //Check if it is root item
        if self.itemCOntainsKey(itemToCheck: item, keyToCheck: "children")
        {
            let currView = leftOutlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            let itemHeader = item as! [String: Any] //Cast
            currView?.textField?.stringValue = (itemHeader["label"] as! String).uppercased()
            return currView
        }
        else
        {
            let currView = leftOutlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
            let currItem = item as! [String:String]
            currView?.textField?.stringValue = currItem["label"]!
            currView?.imageView?.image = NSImage.init(imageLiteralResourceName: currItem["iconName"]!)
            /*
            currView?.textField?.stringValue = item as! String
            if (item as! String == "Quotes") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameUserGuest)}
            if (item as! String == "Fancy") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameBonjour)}
            if (item as! String == "Authors") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameHomeTemplate)}
            if (item as! String == "Themes") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameInfo)}
            if (item as! String == "Big View") {currView?.imageView?.image = NSImage.init(imageLiteralResourceName: NSImageNameNetwork)}
 */
            
            return currView
            
        }
    }
    //Selection changed
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedItem = leftOutlineView.selectedRow
        let dictChosen = self.leftOutlineView.item(atRow: selectedItem) as! Dictionary<String, String>
        print(dictChosen["label"]!)
        
        let tabController = self.childViewControllers[0] as! NSTabViewController
        
        switch dictChosen["label"]! {
        case "Quote":
            tabController.selectedTabViewItemIndex = 0
        case "Authors":
            let currentTabController = tabController.childViewControllers[3] as! GroupedController
            currentTabController.typeOfGrouping="isAbout.topic"
            tabController.selectedTabViewItemIndex = 3
        case "Topics":
            let currentTabController = tabController.childViewControllers[3] as! GroupedController
            currentTabController.typeOfGrouping="fromAuthor.name"
            tabController.selectedTabViewItemIndex = 4
        case "Big View":
            tabController.selectedTabViewItemIndex = 2
        case "Single View":
            tabController.selectedTabViewItemIndex = 1
        default:
            tabController.selectedTabViewItemIndex = 1
        }
        
        
        //THIS COMMENTED CODE WORKS
        
        /*
        switch selectedItem {
        case 1, 2:
            let tabController = self.childViewControllers[0] as! NSTabViewController
            //print("\(selectedItem) is \(dictChosen["label"])")
            tabController.selectedTabViewItemIndex = selectedItem-1
        case 4:
            let tabController = self.childViewControllers[0] as! NSTabViewController
            let currentTabController = tabController.childViewControllers[selectedItem-1] as! GroupedController
            currentTabController.typeOfGrouping="fromAuthor.name"
            tabController.selectedTabViewItemIndex = 5-1
            //print("\(selectedItem) is \(dictChosen["label"])")
        case 5:
            let tabController = self.childViewControllers[0] as! NSTabViewController
            let currentTabController = tabController.childViewControllers[selectedItem-1] as! GroupedController
            currentTabController.typeOfGrouping="isAbout.topic"
            tabController.selectedTabViewItemIndex = 5-1
            //print("\(selectedItem) is \(dictChosen["label"])")
        default:
            print("Something else selected")
        }
 */
    }
    
}

extension ViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
       //Check if it is root item
        if item == nil {
            return fileTree!.count
        }
        else {
            let arrayItems = (item as! [String:Any])["children"]
            return (arrayItems as! NSArray).count
        }
    }
    
    //Formats group cells
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {

        return self.itemCOntainsKey(itemToCheck: item, keyToCheck: "isGroup")
    }
    
    //Wheather each item is expandable or not
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        return self.itemCOntainsKey(itemToCheck: item, keyToCheck: "isGroup")
    }
    
    //Return the item depending ong the herarchy level
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        if (item == nil) {
            return fileTree![index]
        } // Root
        else if (self.itemCOntainsKey(itemToCheck: item!, keyToCheck: "isGroup")){
            return ((item as! Dictionary<String, Any>)["children"] as! Array)[index]
        }
        else{
            return ""
        }
    }
}

extension Array {
    
    //Random function to array
    func randomElement() -> Element  {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

