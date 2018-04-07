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
        
       //Gets the Parent Playlist
        let listsPlaylist = Tags.firstWith(predicate: NSPredicate(format: "tagName == %@", "Lists"), inContext: moc) as? Tags

        //Get the name of the New playlist
        let alert = NSAlert.createAlert(title: "Tags", message: "Please enter name:", style: .informational, withCancel: true, andTextField: true)
        let result = alert.runModal()
        if  result == .alertFirstButtonReturn{
            if let textField = alert.accessoryView as? NSTextField,
                textField.stringValue.count > 1 {
                
                //Sets the new one
                let newPlay = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: self.moc) as! Tags
                newPlay.tagName = textField.stringValue
                newPlay.isInTag = listsPlaylist
                try! self.moc.save()
                
            }
        }
    }
}

//MARK: - Extensions
//MARK: NSOutlineViewDelegate
extension PlaylistController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
            let currItem = (item as! NSTreeNode).representedObject as! Tags
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
        guard let sPlaylist = sNode?.representedObject as? Tags else {return}
      
        //Change the predicate of the main controller
        if let sharedItems = self.representedObject as? SharedItems {
            sharedItems.mainQuoteController?.fetchPredicate=NSPredicate(format: "hasTags.tagName CONTAINS[CD] %@", sPlaylist.tagName!)
            sharedItems.mainQuoteController?.fetch(nil)

        }     
    }

}

//MARK: NSOutlineViewDataSource
extension PlaylistController: NSOutlineViewDataSource{

    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        guard let destItem = (item as? NSTreeNode)?.representedObject as? Tags else {
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
        let destPlaylist2 = (item as! NSTreeNode).representedObject as! Tags
        destPlaylist2.addToQuotesInTag(NSSet(array: quotesS))
        try! moc.save()
        self.playlistOutlineView.reloadData()

        return true
    }
}




