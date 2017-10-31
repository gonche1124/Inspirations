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
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    //IBOutlets
    @IBOutlet var quotesArrayController: NSArrayController!
    @IBOutlet weak var columnsTable: NSTableView!
    
}

//MARK: - Extensions
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

////@objc(TransformerFromBinaryToFavorite)
//class TransformerFromBinaryToFavorite: ValueTransformer {
//    
//    //What am I converting from
//    override class func transformedValueClass() -> AnyClass {
//        return NSString.self
//    }
//    
//    //Are reverse tranformation allowed?
//    override class func allowsReverseTransformation() -> Bool {
//        return false;
//    }
//    
//    
//    func transformedValue(value: AnyObject?) -> AnyObject? { //Perform transformation
//        //guard let type = value as? NSNumber else { return nil }
//        return "test1" as AnyObject
//        
//    }
//    
//    
//}



