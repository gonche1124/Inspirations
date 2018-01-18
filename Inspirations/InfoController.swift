//
//  InfoController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/10/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


class InfoController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        _=self.view.subviews.filter({$0.tag == 2}).map({($0 as! NSTextField).drawsBackground=areItemsEditable})
    }
    
    override func viewWillAppear() {
        if let ro = NSApp.windows[0].contentViewController?.representedObject as? SharedItems{
            self.representedObject=ro
        }
//        for item in (NSApp.windows[0].contentViewController?.childViewControllers)!{
//            if let tabView = item as? NSTabViewController {
//                if let table = tabView.childViewControllers[tabView.selectedTabViewItemIndex] as? CocoaBindingsTable{
//                    print(table.quotesArrayController.selectionIndexes.count)
//                    print(table.columnsTable.selectedRowIndexes.count)
//                }
//            }
//        }
        super.viewWillAppear()
    }
   
    
    @IBAction func makeEditable(_ sender: NSButton) {
        //Change button title and variable.
        self.areItemsEditable = !self.areItemsEditable
        editButton.title = (areItemsEditable) ? "Save": "Edit"
        
        //Change interface to make items editable.
        _=self.view.subviews.filter({$0.tag == 2}).map({($0 as! NSTextField).drawsBackground=areItemsEditable})
        try! moc.save()
        
    }
    
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet var quotesController: NSArrayController!
    @IBOutlet var playlistController: NSArrayController!
    @IBOutlet var tagsControlller: NSArrayController!
    
    @objc dynamic lazy var areItemsEditable: Bool = false
        
}

//Token Field Delegate
extension InfoController: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        print(substring)
        if tokenField.identifier==NSUserInterfaceItemIdentifier("playlistTokenField") {
            return (playlistController.arrangedObjects as! [Playlist]).map({$0.pName!}).filter({$0.hasPrefix(substring)})
        }
        else {
            return (tagsControlller.arrangedObjects as! [Tags]).map({$0.tag!}).filter({$0.hasPrefix(substring)})
        }
    }
    
    //Strings displayed in the tokenfield.
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        if tokenField.identifier==NSUserInterfaceItemIdentifier("playlistTokenField"){
            return (representedObject as? Playlist)?.pName!
        }
        else if tokenField.identifier==NSUserInterfaceItemIdentifier("tagsTokenField"){
            return (representedObject as? Tags)?.tag!
        }
        return nil
    }
    
    //Add Entities when a name is entered.
    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
        
        //Playlist token field.
        if tokenField.identifier==NSUserInterfaceItemIdentifier("playlistTokenField"){
            let newPlaylist = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: moc) as! Playlist
            newPlaylist.pName = tokens[0] as? String
            return [newPlaylist]//(representedObject as? Playlist)?.pName!
        }
        //Tags toekn field
        else if tokenField.identifier==NSUserInterfaceItemIdentifier("tagsTokenField"){
            let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: moc) as! Tags
            newTag.tag = tokens[0] as? String
            return [newTag]
        }
        return tokens
        
    }
    
    
    
}
