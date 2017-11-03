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
        
        //Does nothing
//        self.playlistOutlineView.reloadData()
//        self.playlistOutlineView.setNeedsDisplay()
//        self.playlistOutlineView.expandItem(nil, expandChildren: true)
    }
    
    //Variables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //Outlets
    @IBOutlet var treeArrayController: NSTreeController!
    @IBOutlet weak var playlistOutlineView: NSOutlineView!
    
}

//MARK: - Extensions
//MARK: NSOutlineViewDelegate
extension PlaylistController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let typeOfCell : String = (((item as? NSTreeNode)?.isLeaf)! ? "DataCell" : "HeaderCell")
        let currView = self.playlistOutlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeOfCell), owner: self) as? NSTableCellView
        
        //Test to not make editable the Library. NOT WORKING.
        if ((item as! NSTreeNode).parent?.representedObject as? Playlist)?.pName == "Library" {
            currView?.textField?.backgroundColor = NSColor.blue
            currView?.textField?.isEditable=false
            currView?.textField?.isSelectable=false
            print ("It is true")
            }
        currView?.textField?.stringValue = (((item as! NSTreeNode).representedObject as! Playlist).pName?.uppercased())!
        currView?.imageView?.image = NSImage.init(imageLiteralResourceName: "red heart")
        return currView
        
    }
    
    
    //Display Grouped cell
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (!(item as? NSTreeNode)!.isLeaf)
    }
    
    //Selection changed.
    func outlineViewSelectionDidChange(_ notification: Notification) {
        print("Selection is now: \(self.playlistOutlineView.selectedRow)")
    }
}

//MARK: NSOutlineViewDataSource
extension PlaylistController: NSOutlineViewDataSource{
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return (item as! NSTreeNode).representedObject
    }
    
    
    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        let destItem = (item as! NSTreeNode).representedObject as! Playlist
        return NSDragOperation.init(rawValue: destItem.isLeaf ?  1 : 0)
    }
    
    //Perform the Drop, validating the data.
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        //Get source data.
        let data: Data = info.draggingPasteboard().data(forType: NSPasteboard.PasteboardType.fileContents)! as Data
        let rowIndexes = NSKeyedUnarchiver.unarchiveObject(with: data) as! IndexSet
        let quotesSource = ((self.parent as! ViewController).VCPlainTable.quotesArrayController.arrangedObjects) as! NSArray
        
        //Add items to playlits.
        let destPlaylist = (item as! NSTreeNode).representedObject as! Playlist
        let quotesSet: NSMutableSet = destPlaylist.quotesInPlaylist! as! NSMutableSet
        quotesSet.addObjects(from: quotesSource.objects(at: rowIndexes) )
        destPlaylist.quotesInPlaylist = quotesSet
        
        //Save
        try! destPlaylist.managedObjectContext?.save()
        
        return true
    }
}

//Collection count becasue bindings is not working.
class SetToCount: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value == nil {
            return nil
        }else {
            return "\((value as! NSSet).count)"
        }
    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
}


