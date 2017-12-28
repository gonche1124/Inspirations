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
        //To erase
        //testCode()
        
        //Add observers.
        let moc = (NSApp.delegate as? AppDelegate)?.managedObjectContext
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: moc)
            //notiCenter.addObserver(self, forKeyPath: #managedObjectContextDidSave, options: [], context: nil)
        
        
        //Initialize and add the different Views that the App will use. (Check if efficient management of resources).
        let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        VCPlainTable = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCPlainTable")) as! CocoaBindingsTable
        VCQuoteTable = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCQuotesTable")) as! QuoteController
        VCBigView = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCBigView")) as! BigViewController
        VCGroupedMixTable = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VCGroupedMix")) as! AuthorsController
        VCCollectionView = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:"VCCollection")) as! CollectionController
        VCTheme = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:"VCTags")) as! ThemesController
        
        //Add controllers
        self.addChildViewController(VCPlainTable)
        self.addChildViewController(VCQuoteTable)
        self.addChildViewController(VCBigView)
        self.addChildViewController(VCGroupedMixTable)
        self.addChildViewController(VCCollectionView)
        self.addChildViewController(VCTheme)
        
        
        //Set default view
        VCBigView.view.frame = self.containerView.bounds
        self.containerView.addSubview(VCBigView.view)
        //TODO: get current controller. unify searchfield delegate.
        
    }
    
    //Called when an object gets updated.
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let moc = (NSApp.delegate as! AppDelegate).managedObjectContext
        if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            //Delete Authors & Themes.
            _=updated.filter({$0.className == "Author"}).filter({($0 as! Author).hasQuotes?.count==0}).map({moc.delete($0)})
            _=updated.filter({$0.className == "Theme"}).filter({($0 as! Theme).fromQuote?.count==0}).map({moc.delete($0)})
        }
    }
    

    //Selects the view controller to show depending on the button selected.
    @IBAction func changeViewOfQuotes(_ sender: NSSegmentedControl) {
        //Remove all views.
        for cView in self.containerView.subviews {
            cView.removeFromSuperview()
        }
        
        //Pick view depending on button pressed.
        switch sender.indexOfSelectedItem {
        case 0:
            VCPlainTable.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCPlainTable.view)
        case 1:
            VCQuoteTable.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCQuoteTable.view)
        case 2:
            VCBigView.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCBigView.view)
        case 3:
            VCGroupedMixTable.view.frame = self.containerView.bounds
            VCGroupedMixTable.authorsTable.reloadData()
            VCGroupedMixTable.authorsTable.expandItem(nil, expandChildren: true)
            self.containerView.addSubview(VCGroupedMixTable.view)
        case 4:
            VCTheme.view.frame = self.containerView.bounds
            VCTheme.tagsOultineView.reloadData()
            VCTheme.tagsOultineView.expandItem(nil, expandChildren: true)
            self.containerView.addSubview(VCTheme.view)
            
            
            //VCGroupedMixTable.view.frame = self.containerView.bounds
            
//            VCGroupedMixTable.typeOfGrouping = "isAbout.topic"
//            VCGroupedMixTable.groupedTable.reloadData()
//            VCGroupedMixTable.groupedTable.expandItem(nil, expandChildren: true)
//            self.containerView.addSubview(VCGroupedMixTable.view)
        default:
    
            
            VCCollectionView.view.frame = self.containerView.bounds
            self.containerView.addSubview(VCCollectionView.view)
        }
        
    }

    
    //MARK: - Export
    //Connected through first responder
    @IBAction func exportCoreModel(_ sender: NSButton) {
        importExport().exportAllTheQuotes()
    }
    
    //MARK: - Variables
    //Variables
    fileprivate lazy var managedContext = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext

    //Controllers of different Views Final
    var VCPlainTable : CocoaBindingsTable!
    var VCQuoteTable : QuoteController!
    var VCBigView : BigViewController!
    var VCGroupedMixTable : AuthorsController!
    var VCCollectionView : CollectionController!
    var VCTheme : ThemesController!
    
    //Outlets
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var searchQuote: NSSearchField!
    lazy var searchQuote2 : NSSearchField! = {
        let items = self.view.window?.toolbar?.items
        let thisSearch = items?.first(where: {$0.itemIdentifier.rawValue == "searchToolItem"})
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
            let records = try managedContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Quote"))
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
