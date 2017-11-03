//
//  CocoaBindingsTable.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/19/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa

class CocoaBindingsTable: NSViewController {
    
    //View will Load
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Set delegate of searcfiled when view will appear.
    override func viewWillAppear() {
        super.viewWillAppear()
        (self.parent as? ViewController)?.searchQuote.delegate=self
    }
    
    //Variables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //IBOutlets
    @IBOutlet var quotesArrayController: NSArrayController!
    @IBOutlet weak var columnsTable: NSTableView!
    
}




//MARK: - Extensions

//MARK: NSTableViewDelegate
extension CocoaBindingsTable: NSTableViewDelegate{
    
    //Dragging
   
}

extension CocoaBindingsTable: NSTableViewDataSource{
    
    //Dragging methods
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        //Get data.
        //let dataToDrag = (self.quotesArrayController.arrangedObjects as! NSArray).objects(at: rowIndexes) as! [Quote]
        //let firstObjectURI = dataToDrag.first?.objectID.uriRepresentation()
        //pboard.declareTypes(["NSP"], owner: self)
        
        pboard.setData(NSKeyedArchiver.archivedData(withRootObject: rowIndexes), forType: NSPasteboard.PasteboardType.fileContents)
        //NSPasteboard.Name.generalPboard
        print (rowIndexes)
        //print(dataToDrag)
        return true
    }

}



extension CocoaBindingsTable: NSSearchFieldDelegate{
    
    //Gts called when user ends searhing
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.quotesArrayController.filterPredicate = nil
        self.columnsTable.reloadData()
        (self.parent as? ViewController)?.updateInfoLabel(parameter: "All")
    }
    
    //Gets called when user searches
    override func controlTextDidChange(_ obj: Notification) {
        let tempSearch = (obj.object as? NSSearchField)!.stringValue
        if tempSearch != "" {
            self.quotesArrayController.filterPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@", tempSearch)
            self.columnsTable.reloadData()
            (self.parent as? ViewController)?.updateInfoLabel(parameter: (self.quotesArrayController.arrangedObjects as! NSArray).count)
        }
    }
    
}

//Heart transformer to image.
class BooleanToImage: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSImage.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value == nil {
            return nil
        }else {
            return NSImage.init(imageLiteralResourceName: (value as! Bool) ? "red heart":"grey heart")
        }
    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
}

















