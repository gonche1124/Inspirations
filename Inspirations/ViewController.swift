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
        
        //Add observers.
        //let moc = (NSApp.delegate as? AppDelegate)?.managedObjectContext
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: moc)
            //notiCenter.addObserver(self, forKeyPath: #managedObjectContextDidSave, options: [], context: nil)
        
        //Not working
        let toolItems = NSApp.mainWindow?.toolbar?.items
        if let segControl = toolItems?.first(where: {$0.itemIdentifier.rawValue=="segmentButton"})?.view as? NSSegmentedControl {
            segControl.addObserver(self, forKeyPath: "selectedSegmentIndex", options: [], context: nil)
        }
        
        if let toolBar = self.view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue=="segmentButton"})?.view as? NSSegmentedControl{
            toolBar.addObserver(self, forKeyPath: "selectedSegmentIndex", options: [], context: nil)
        }
        
    }
    
    override var representedObject: Any?{
        didSet{
            for item in self.childViewControllers{
                item.representedObject=representedObject
                for item2 in item.childViewControllers{
                    item2.representedObject=representedObject
                }
            }
        }
    }
    
    //Function from observers.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath=="selectedSegmentIndex" {
            print ("index changed to")
        }
    }
    
    //Called when an object gets updated.
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        //let moc = (NSApp.delegate as! AppDelegate).managedObjectContext
        if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            //Delete Orphan Authors & Themes.
            _=updated.filter({$0.className == "Author"}).filter({($0 as! Author).hasQuotes?.count==0}).map({moc.delete($0)})
            _=updated.filter({$0.className == "Theme"}).filter({($0 as! Theme).fromQuote?.count==0}).map({moc.delete($0)})
        
            //Update Favorites playlist.
            if let qList = updated.filter({$0.className=="Quote" && $0.changedValuesForCurrentEvent()["isFavorite"] != nil}) as? Set<Quote>,let favPl=Playlist.firstWith(predicate: NSPredicate(format: "pName == %@", "Favorites"), inContext: moc) as? Playlist {
      
                _=qList.filter({$0.isFavorite==true}).map({$0.addToInPlaylist(favPl)})
                _=qList.filter({$0.isFavorite==false}).map({$0.removeFromInPlaylist(favPl)})
            }
        
        }
        
        if let inserted=userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count>0, let qList = inserted.filter({$0.className=="Quote"}) as? Set<Quote> {
           
            //Using extensions to add default "Main" playlist. Should move this to account if user deletes playlist by error?.
            if let mainPl=Playlist.firstWith(predicate: NSPredicate(format: "pName == %@", "Main"), inContext: moc) as? Playlist{
                _=qList.map({$0.addToInPlaylist(mainPl)})
            }
        }
    }
    

    //Selects the view controller to show depending on the button selected.
    @IBAction func changeViewOfQuotes(_ sender: NSSegmentedControl) {
        
        guard let tabView = self.childViewControllers.first(where: {$0.className == "NSTabViewController"})  as? NSTabViewController else {return}
        tabView.selectedTabViewItemIndex = sender.selectedSegment
        
    }

    //MARK: - Variables
    @IBOutlet var quoteController: NSArrayController!

    
    
    
    //MARK: - Export
    //Connected through first responder
    @IBAction func exportCoreModel(_ sender: NSButton) {
        importExport().exportAllTheQuotes()
    }
    
    //MARK: - Variables
    
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
    
    //Function to print the number of elemtns in core data
//    func printCurrentData(){
//
//        //get context
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//
//        //Retrieve the current Data.
//        var listQuotes = [Quote]()//[NSManagedObject]()
//        do{
//            let records = try managedContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Quote"))
//            if let records = records as? [Quote]{
//                listQuotes=records
//            }
//            print("number of records is: \(listQuotes.count)")
//            self.informationLabel.stringValue = "Showing \(listQuotes.count) of \(listQuotes.count)"
//
//
//        }catch{
//            print("Could not print the records")
//        }
//    }
}
