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
//        let toolItems = NSApp.mainWindow?.toolbar?.items
//        if let segControl = toolItems?.first(where: {$0.itemIdentifier.rawValue=="segmentButton"})?.view as? NSSegmentedControl {
//            segControl.addObserver(self, forKeyPath: "selectedSegmentIndex", options: [], context: nil)
//        }
        
//        if let toolBar = self.view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue=="segmentButton"})?.view as? NSSegmentedControl{
//            toolBar.addObserver(self, forKeyPath: "selectedSegmentIndex", options: [], context: nil)
//        }
        
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
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        if keyPath=="selectedSegmentIndex" {
//            print ("index changed to")
//        }
//    }
    
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
    
    //Connected through first responder.
    @IBAction func setSelectedQuoteAsDesktopBackground(_ sender: NSButton){
        print ("Set as background image.")
        
        //get current quote(first)
        let selectedQuote:Quote = ((representedObject as! SharedItems).mainQuoteController?.selectedObjects.first as? Quote)!
        
        //Get the path to the desktop image.
        let imagePathAlias = NSWorkspace().desktopImageURL(for: NSScreen.main!)
        let imagePath: NSURL = try! NSURL.init(resolvingAliasFileAt: imagePathAlias!, options: NSURL.BookmarkResolutionOptions())
        
        //TODO: Check for duplicate in desktop image.
        //Check if it already has a quote, if so, delete and ind original path.
    
        //duplicate path/image.
        //TODO: Handle duplicate items.
        let budleID = Bundle.main.bundleIdentifier
        let fileManager = FileManager.default
        let possibleUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let newName = budleID!+"/"+(imagePath.lastPathComponent?.replacingOccurrences(of: ".jpg", with: "-new.jpg"))!
        let newURL = NSURL(fileURLWithPath: newName, relativeTo: possibleUrl.first)
        try! fileManager.copyItem(at: imagePath.absoluteURL!, to: newURL as URL)
        
        //Set Quote.
        importExport().mergeThis(quote: selectedQuote, onImageWithPath: newURL)
        
        
        //Append text.
        
        //Set as background image.
        //https://gist.github.com/greenywd/d7fdc3d3933fc42f3aaa2d4fccca3944
        //https://gist.github.com/pthrasher/12e06e24c2f6c542dfa1
        
        
    }
    
    
    //MARK: - Variables
    
    //Outlets
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var informationLabel: NSTextField!
    
}
