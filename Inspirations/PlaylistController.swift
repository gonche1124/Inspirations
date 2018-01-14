//
//  PlaylistController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/1/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class PlaylistController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.playlistOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String as String)])
        
        //Sort descriptors.
        treeArrayController.sortDescriptors = [NSSortDescriptor(key: "pName", ascending: true)]
        
        //Outlineview IMPROVE
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.playlistOutlineView.expandItem(nil, expandChildren: true)
        }
    }
    
    //Outlets
    @IBOutlet var treeArrayController: NSTreeController!
    @IBOutlet weak var playlistOutlineView: NSOutlineView!
    
    //Add item.
    @IBAction func addItem(_ sender: Any) {
    
        //Ask for Name:
        //TODO: Implement ask for playlistName
        
//        //Gets the big Playlist
        let frequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        frequest.predicate = NSPredicate(format: "pName == %@", "Lists")
        let bigPlaylist = try! moc.fetch(frequest) as! [Playlist]

        //Sets the new one
        let newPlay = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: moc) as! Playlist
        newPlay.pName = "PlaylistYYY3"
        newPlay.isInPlaylist = bigPlaylist.first
        
        //Save
        try! self.moc.save()
    }
}

//MARK: - Extensions
//MARK: NSOutlineViewDelegate
extension PlaylistController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
            let currItem = (item as! NSTreeNode).representedObject as! Playlist
            let typeOfCell: String = (currItem.isLeaf) ? "DataCell": "HeaderCell"
            let currView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
        return currView
    }

    //Display Grouped cell
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (!(item as? NSTreeNode)!.isLeaf)
    }

    
    //Selection changed.
    func outlineViewSelectionDidChange(_ notification: Notification) {

        //Get playlist item
        guard let outlineView = notification.object as? NSOutlineView else {return} //Check is outlineView
        let sNode = outlineView.item(atRow: outlineView.selectedRow) as? NSTreeNode
        if (!(sNode?.isLeaf)!){return} //Check if is not playlist
        guard let sPlaylist = sNode?.representedObject as? Playlist else {return}
      
        
        
        //FIX - Make conform to protocols to get arrayController from NSControllers.
        let tabController = NSApp.mainWindow?.contentViewController?.childViewControllers.first(where: {$0.className=="NSTabViewController"}) as? NSTabViewController
        //let qArray2 = tabController?.childViewControllers[(tabController?.selectedTabViewItemIndex)!].currentQuoteController
        let qArray = (tabController?.childViewControllers[(tabController?.selectedTabViewItemIndex)!] as? CocoaBindingsTable)?.quotesArrayController
        qArray?.fetchPredicate=NSPredicate(format: "inPlaylist.pName CONTAINS[CD] %@", sPlaylist.pName!)
     
        
        
        
        //let qController = NSApp.mainWindow?.contentView?.subviews.first(where: {$0.className==NST})
        
        
        //let currPredicate = NSPredicate(format: "ANY inPlaylist.pName = %@",(sPlaylist.pName!))
        //(self.parent as! ViewController).VCPlainTable.quotesArrayController.filterPredicate = currPredicate
        // TODO: change for current controller.

    }

    //Check if item should be selectable
//    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
//        return (item as! NSTreeNode).isLeaf
//    }
}

//MARK: NSOutlineViewDataSource
extension PlaylistController: NSOutlineViewDataSource{

    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        guard let destItem = (item as? NSTreeNode)?.representedObject as? Playlist else {
            return NSDragOperation.init(rawValue: 0)
        }
        return NSDragOperation.init(rawValue: destItem.isLeaf ?  1 : 0)
    }

    //Perform the Drop, validating the data.
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

        //WWDC 2016 method
        let sURL: [URL] = info.draggingPasteboard().pasteboardItems!.map({URL.init(string: $0.string(forType: .string)!)!})
        let sOBID: [NSManagedObjectID] = sURL.map({(moc.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0))!})
        let quotesS = sOBID.map({moc.object(with: $0 )})

        //Insert objects.
        let destPlaylist2 = (item as! NSTreeNode).representedObject as! Playlist
        destPlaylist2.addToQuotesInPlaylist(NSSet(array: quotesS))
        try! moc.save()
        self.playlistOutlineView.reloadData()

        return true
    }
}




