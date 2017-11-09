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
        //SEE IF I CAN OPTIMIZE THIS!!!!!
        //self.parent?.view.window?.toolbar
        let toolB = self.parent?.view.window?.toolbar?.items
        let test = try! toolB?.first(where: {$0.itemIdentifier._rawValue == "searchToolItem"})
        print ("This: \(test)")
        //print("This is: \(toolB?.first(where:{($0.view?.identifier)!.rawValue=="toolBarSearch"}))")
        for toolIt in toolB! {
            print(toolIt.view?.className)
            if let searchF = toolIt.view as? NSSearchField {
                searchF.delegate = self
            }
        }
        //print(self.parent?.view.window?.toolbar?.items.)
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
        //Set data to be pasted on pasteboard
        pboard.setData(NSKeyedArchiver.archivedData(withRootObject: rowIndexes), forType: NSPasteboard.PasteboardType.fileContents)

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

















