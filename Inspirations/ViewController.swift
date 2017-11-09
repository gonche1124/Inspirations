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
        //printPlaylistData()
        
        //To comment.
        //addTempDefaultValues()
        
        //Initialize and add the different Views that the App will use. (Check if efficient management of resources).
        VCPlainTable = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCPlainTable")) as! CocoaBindingsTable
        VCQuoteTable = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCQuotesTable")) as! QuoteController
        VCBigView = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCBigView")) as! BigViewController
        VCGroupedMixTable = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCGroupedMix")) as! GroupedController
        VCCollectionView = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:"VCCollection")) as! CollectionController
        //Add controllers
        self.addChildViewController(VCPlainTable)
        self.addChildViewController(VCQuoteTable)
        self.addChildViewController(VCBigView)
        self.addChildViewController(VCGroupedMixTable)
        self.addChildViewController(VCCollectionView)
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
        else if sender.indexOfSelectedItem == 4 {
            VCGroupedMixTable.view.frame = self.containerView.bounds
            VCGroupedMixTable.typeOfGrouping = "isAbout.topic"
            VCGroupedMixTable.groupedTable.reloadData()
            VCGroupedMixTable.groupedTable.expandItem(nil, expandChildren: true)
            self.containerView.addSubview(VCGroupedMixTable.view)
        }
        else {
            VCCollectionView.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCCollectionView.view)
        }
        
    }

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
        
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
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
    


    //MARK: - Export
    @IBAction func exportCoreModel(_ sender: NSButton) {
        importExport().exportAllTheQuotes()
    }
    
    //MARK: - Variables
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")

    
    //Controllers of different Views Final
    var VCPlainTable : CocoaBindingsTable!
    var VCQuoteTable : QuoteController!
    var VCBigView : BigViewController!
    var VCGroupedMixTable : GroupedController!
    var VCCollectionView : CollectionController!
 
    //Outlets
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var searchQuote: NSSearchField!
    lazy var searchQuote2 : NSSearchField! = {
        let items = self.view.window?.toolbar?.items
        let thisSearch = try! items?.first(where: {$0.itemIdentifier.rawValue == "searchToolItem"})
        return thisSearch!.view as! NSSearchField
    }()
    
    // MARK: - Helpers
    func updateInfoLabel(parameter: Any){
        self.informationLabel.stringValue = "Showing \(parameter) of the 33 records"
    }
    
    //To ERASE, only used for adding default values.
    func addTempDefaultValues(){
        //get context
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
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
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
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
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Retrieve data.
        let fetchR = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        let lists : [Playlist] = try! managedContext.fetch(fetchR) as! [Playlist]
        print ("number of playlists is: \(lists.count)")
        for list in lists {
            let quotes = list.quotesInPlaylist
            print ("Playlist \(list.pName!) has \(quotes!.count) quotes")
            list.pName == "Favorites" ? list.pType="red heart" : nil
            list.pName == "Main" ? list.pType="BookShelf":nil
            try! list.managedObjectContext?.save()
        }
        //print (lists)
        
    }
}
