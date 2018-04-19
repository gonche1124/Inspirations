//
//  LeftController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/2/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class LeftController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Regoster for dragging.
        self.sourceItemView?.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String as String)])

        //Sort descriptors.
        treeArrayController.sortDescriptors = [NSSortDescriptor(key: "tagName", ascending: true)]

        //Outlineview IMPROVE
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            (self.sourceItemView as? NSOutlineView)?.expandItem(nil, expandChildren: true)
            //self.sourceItemView.expandItem(nil, expandChildren: true)
        }
        
    }

    
 
    //MARK: - Outlets
    @IBOutlet weak var leftList: NSOutlineView!
    @IBOutlet var treeArrayController: NSTreeController!
    //lazy var customSort:NSSortDescriptor = NSSortDescriptor(key: "tagName", ascending: true)
    
}


//MARK: - Extensions
extension LeftController: NSSearchFieldDelegate, NSTextFieldDelegate{
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.treeArrayController.fetchPredicate=NSPredicate(format: "isInTag == nil")
        (self.sourceItemView as? NSOutlineView)?.reloadData()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let searchBar=obj.object as? NSSearchField
        
        if searchBar?.stringValue=="" {
            self.treeArrayController.fetchPredicate=NSPredicate(format: "isInTag == nil")
        }else{
            self.treeArrayController.fetchPredicate=NSPredicate(format: "(tagName CONTAINS[CD] %@)", (searchBar?.stringValue)!)
        }
        
        //Update interface.
        (self.sourceItemView as? NSOutlineView)?.reloadData()
        
    }
    
}


extension LeftController: NSOutlineViewDelegate{
    
    //Choose the right cell to show.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard  let currItem = (item as? NSTreeNode)?.representedObject as? Tags else {return nil}
        let typeOfCell: String = (currItem.subTags?.count==0) ? "SecondLevel": "FirstLevel"
        let currView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
        return currView
        
    }
    
    //Display Grouped cell --Formats table as a sourcelist.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        guard let item = item as? NSTreeNode else {return false}
        return (!(item).isLeaf)
    }
}

//MARK: NSOutlineViewDataSource
extension LeftController: NSOutlineViewDataSource{
    
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
        //self.playlistOutlineView.reloadData()
        
        return true
    }
}