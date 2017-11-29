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
        playlistOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.fileContents])
        playlistOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
        
        
        //Sort descriptors
        let sortDesc = NSSortDescriptor(key: "pName", ascending: true)
        treeArrayController.sortDescriptors = [sortDesc]
        
        //Outlineview NOT WORKING.
        playlistOutlineView.expandItem(nil, expandChildren: true)
    }
    

    
    //Variables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext

    //TESTING!!!!!!!
//     lazy var playlistController: NSFetchedResultsController<Playlist> = {
//        // Create Fetch Request
//        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pName", ascending: true)]
//
//        // Create Fetched Results Controller
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.moc, sectionNameKeyPath: "isInPlaylist", cacheName: nil)
//        // Configure Fetched Results Controller
//        //fetchedResultsController.delegate = self
//        return frc
//    }()
    
    //Outlets
    @IBOutlet var treeArrayController: NSTreeController!
    @IBOutlet weak var playlistOutlineView: NSOutlineView!
    
    //Add item.
    @IBAction func addItem(_ sender: Any) {
    
        //let myIndexPath = IndexPath(
        //treeArrayController.selectedNodes.first.add
        treeArrayController.addChild(sender)
        //treeArrayController.add(sender)
        playlistOutlineView.reloadData()
    }
    
    
}

//MARK: - Extensions
//MARK: NSOutlineViewDelegate
extension PlaylistController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
            let currItem = (item as! NSTreeNode).representedObject as! Playlist
            let typeOfCell: String = (currItem.isLeaf) ? "DataCell": "HeaderCell"
            let currView = playlistOutlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
        return currView
    }

//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//
//        let currItem = (item as! NSTreeNode).representedObject as! Playlist
//        let typeOfCell: String = (currItem.isLeaf) ? "DataCell": "HeaderCell"
//        let currView = playlistOutlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
//
//        //Set up
//        if currItem.isLeaf {
//            currView?.imageView?.image = NSImage.init(imageLiteralResourceName: currItem.pType!)
//            (currView?.viewWithTag(1) as! NSButton).title = "\(currItem.quotesInPlaylist?.count ?? 0)"
//            currView?.textField?.stringValue = (currItem.pName)!
//        }
//        else {
//            currView?.textField?.stringValue = (currItem.pName?.uppercased())!
//        }
//
//        currView?.layoutSubtreeIfNeeded()
//        return currView
//
//    }

    //Display Grouped cell
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (!(item as? NSTreeNode)!.isLeaf)
    }

    //Selection changed.
    func outlineViewSelectionDidChange(_ notification: Notification) {

        //playlistOutlineView.expandItem(nil, expandChildren: true)
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        let sNode = outlineView.item(atRow: outlineView.selectedRow) as? NSTreeNode
        let sPlaylist = sNode?.representedObject as? Playlist

        if !(sPlaylist?.isLeaf )! { return}
        let currPredicate = NSPredicate(format: "ANY inPlaylist.pName = %@",(sPlaylist?.pName!)!)
        //(self.parent as! ViewController).VCPlainTable.quotesArrayController.filterPredicate = currPredicate
        // TODO: change for current controller.

    }

    //Check if item should be selectable
//    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
//        return (((item as! NSTreeNode).representedObject as? Playlist)?.isLeaf)!
//    }
}

//MARK: NSOutlineViewDataSource
extension PlaylistController: NSOutlineViewDataSource{

//    //Sets the object represented. Mandatory
//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//        return (item as! NSTreeNode).representedObject
//    }
//
//    //Number of children of current item. Mandatory.
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        guard let currItem = item as? NSTreeNode else {
//            return (treeArrayController.arrangedObjects.children?.count)!
//        }
//        return currItem.children!.count
//    }
//
//    //Gets the child. Mandatory
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//
//        guard let nodeItem = item as? NSTreeNode else {
//            return treeArrayController.arrangedObjects.children![index]
//        }
//        return nodeItem.children![index]
//    }
//
//    //Check if item is expandable. Mandatory
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        return !(item as! NSTreeNode).isLeaf
//    }

    //-------------- Drag n' Drop

    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        guard let destItem = (item as? NSTreeNode)?.representedObject as? Playlist else {
            return NSDragOperation.init(rawValue: 0)
        }
        return NSDragOperation.init(rawValue: destItem.isLeaf ?  1 : 0)
    }

    //Perform the Drop, validating the data.
    //TODO: Simplify code
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

        //Test to Drag Objects instead of index.
        let selectedData = info.draggingPasteboard().data(forType: NSPasteboard.PasteboardType.fileContents)!
        let selectedURI = NSKeyedUnarchiver.unarchiveObject(with: selectedData) as! NSArray
        let objectsIDs = selectedURI.map({moc.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0 as! URL)})
        let quotesSelected = objectsIDs.map({moc.object(with: $0 as! NSManagedObjectID)})

        //Insert objects.
        let destPlaylist2 = (item as! NSTreeNode).representedObject as! Playlist
        destPlaylist2.addToQuotesInPlaylist(NSSet(array: quotesSelected))
        try! (NSApplication.shared.delegate as! AppDelegate).managedObjectContext.save()
        self.playlistOutlineView.reloadData()

        return true
    }
}




