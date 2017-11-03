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
        //self.playlistOutlineView.expandItem(nil, expandChildren: true)
        self.playlistOutlineView.register(forDraggedTypes: [kUTTypeItem as String])
        
    }
    
    //Variables
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    //Outlets
    @IBOutlet var treeArrayController: NSTreeController!
    @IBOutlet weak var playlistOutlineView: NSOutlineView!
    
}

//MARK: - Extensions
//MARK: NSOutlineViewDelegate
extension PlaylistController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let typeOfCell : String = (((item as? NSTreeNode)?.isLeaf)! ? "DataCell" : "HeaderCell")
        let currView = self.playlistOutlineView.make(withIdentifier: typeOfCell, owner: self) as? NSTableCellView
        return currView
        
    }
    
    //Display Grouped cell
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (!(item as? NSTreeNode)!.isLeaf)
    }
}

//MARK: NSOutlineViewDataSource
extension PlaylistController: NSOutlineViewDataSource{
    
    //Drag
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        return true
    }
    
    //Validate if dropping is allowed.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        let destItem = (item as! NSTreeNode).representedObject as! Playlist
        return NSDragOperation.init(rawValue: destItem.isLeaf ?  1 : 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        //Get source data.
        let data: Data = info.draggingPasteboard().data(forType: NSGeneralPboard)! as Data
        let rowIndexes: IndexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as! IndexSet
        let quotesSource = ((self.parent as! ViewController).VCPlainTable.quotesArrayController.arrangedObjects) as! NSArray
        
        //Add items to playlits.
        let destPlaylist = (item as! NSTreeNode).representedObject as! Playlist
        let quotesSet: NSMutableSet = destPlaylist.quotesInPlaylist! as! NSMutableSet
        quotesSet.addObjects(from: quotesSource.objects(at: rowIndexes) as! [Any])
        destPlaylist.quotesInPlaylist = quotesSet
        
        //Save
        try! destPlaylist.managedObjectContext?.save()
        
        return true
    }
}


