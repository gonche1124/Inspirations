//
//  LeftController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/2/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


import Cocoa


class OldLeftController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Regoster for dragging.
        self.sourceItemView?.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String as String)])

        //Sort descriptors.
        treeArrayController.sortDescriptors = [NSSortDescriptor(key: "tagName", ascending: true)]

        //Outlineview IMPROVE
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            (self.sourceItemView as? NSOutlineView)?.expandItem(nil, expandChildren: true)
        }
        
    }

    
 
    //MARK: - Outlets
    @IBOutlet weak var leftList: NSOutlineView!
    @IBOutlet var treeArrayController: NSTreeController!
    @IBInspectable var selectedBackgroundColor:NSColor = NSColor.selectedControlColor

    //lazy var customSort:NSSortDescriptor = NSSortDescriptor(key: "tagName", ascending: true)
    
}


//MARK: - Search Field
extension OldLeftController: NSSearchFieldDelegate, NSTextFieldDelegate{
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.treeArrayController.fetchPredicate=NSPredicate(format: "isInTag == nil")
        (self.sourceItemView as? NSOutlineView)?.reloadData()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let searchBar=obj.object as? NSSearchField
        
        if searchBar?.stringValue=="" {
            self.treeArrayController.fetchPredicate=NSPredicate(format: "isInTag == nil")
        }else{
            self.treeArrayController.fetchPredicate=NSPredicate(format: "(tagName CONTAINS[CD] %@)", (searchBar?.stringValue)!)
        }
        
        //Update interface.
        guard let listView = self.sourceItemView as? NSOutlineView else {return}
        listView.reloadData()
        listView.expandItem(nil, expandChildren: true)
        
    }
    
}

//MARK: - NSOutlineViewDelegate.
//extension LeftController: NSOutlineViewDelegate{
//    
//    //Choose the right cell to show.
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//        
//        guard  let currItem = (item as? NSTreeNode)?.representedObject as? Tags else {return nil}
//        let typeOfCell: String = (currItem.subTags?.count==0) ? "SecondLevel": "FirstLevel"
//        let currView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
//        return currView
//        
//    }
//    
//    //Display Grouped cell --Formats table as a sourcelist.
//    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
//        guard let item = item as? NSTreeNode else {return false}
//        return (!(item).isLeaf)
//    }
//    
//    //Set fetchPredicate of main Array Controller.
//    func outlineViewSelectionDidChange(_ notification: Notification) {
//        
//        guard let thisTag: Tags = self.treeArrayController.selectedObjects.first as? Tags else {return} //Neeed in case user selects main row
//        let mainQuotecontroller = (self.representedObject as? SharedItems)?.mainQuoteController
//        let predicate: NSPredicate? = (thisTag.smartPredicate != nil) ? NSPredicate(format: thisTag.smartPredicate!): nil
//        mainQuotecontroller?.fetchPredicate=predicate
//    }
//    
//
//    
//    //Check if the item can be selected.
//    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
//        
//        if let selNode = item as? NSTreeNode, let selTag = selNode.representedObject as? Tags{
//            return (selTag.isInTag == nil) ? false:true
//        }
//        return false
//    }
//    
//    //Customize the selection color for the rows.
//    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
//        return MyRowView(color: self.selectedBackgroundColor)
//    }
//}

//MARK: NSOutlineViewDataSource
//extension LeftController: NSOutlineViewDataSource{
//    
//    //Validate if dropping is allowed.
//    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
//        
//        guard let destItem = (item as? NSTreeNode)?.representedObject as? Tags else {
//            return NSDragOperation.init(rawValue: 0)
//        }
//        return NSDragOperation.init(rawValue: destItem.isLeaf ?  1 : 0)
//    }
//    
//    //Perform the Drop, validating the data.
//    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
//        
//        //WWDC 2016 method
//        let sURL: [URL] = info.draggingPasteboard().pasteboardItems!.map({URL.init(string: $0.string(forType: .string)!)!})
//        let sOBID: [NSManagedObjectID] = sURL.map({(moc.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0))!})
//        let quotesS = sOBID.map({moc.object(with: $0 )})
//        
//        //Insert objects.
//        let destPlaylist2 = (item as! NSTreeNode).representedObject as! Tags
//        destPlaylist2.addToQuotesInTag(NSSet(array: quotesS))
//        try! moc.save()
//        
//        return true
//    }
//}
