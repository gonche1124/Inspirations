//
//  WindowController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 1/15/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func windowWillLoad() {
        super.windowWillLoad()
        
        //register Values transformers.
        ValueTransformer.setValueTransformer(CollectionToCount(), forName: NSValueTransformerName(rawValue:"myCollectionToCount"))
        ValueTransformer.setValueTransformer(BooleanToImage(), forName: NSValueTransformerName(rawValue: "BooleanToImage"))
        ValueTransformer.setValueTransformer(SetToCount(), forName: NSValueTransformerName(rawValue:"SetToCount"))
        ValueTransformer.setValueTransformer(stringToImage(), forName: NSValueTransformerName(rawValue:"stringToImage"))
        ValueTransformer.setValueTransformer(SetToCompoundString(), forName: NSValueTransformerName(rawValue:"SetToCompoundString"))
        ValueTransformer.setValueTransformer(SetToArray(), forName: NSValueTransformerName(rawValue:"SetToArray"))
        //ValueTransformer.setValueTransformer(DoNothingTransformer(), forName: NSValueTransformerName(rawValue:"myDoNothingTransformer"))
        
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        //register Values transformers.
//        ValueTransformer.setValueTransformer(CollectionToCount(), forName: NSValueTransformerName(rawValue:"myCollectionToCount"))
//        ValueTransformer.setValueTransformer(BooleanToImage(), forName: NSValueTransformerName(rawValue: "BooleanToImage"))
//        ValueTransformer.setValueTransformer(SetToCount(), forName: NSValueTransformerName(rawValue:"SetToCount"))
//        ValueTransformer.setValueTransformer(stringToImage(), forName: NSValueTransformerName(rawValue:"stringToImage"))
//        ValueTransformer.setValueTransformer(SetToCompoundString(), forName: NSValueTransformerName(rawValue:"SetToCompoundString"))
//        ValueTransformer.setValueTransformer(SetToArray(), forName: NSValueTransformerName(rawValue:"SetToArray"))
//        ValueTransformer.setValueTransformer(DoNothingTransformer(), forName: NSValueTransformerName(rawValue:"myDoNothingTransformer"))

        
        
        
        let sharedItems=SharedItems()
        //self.quoteController.bind(.selectionIndexes, to: sharedItems.selectionIndexes, withKeyPath: "self.selectionIndexes", options: [:])
        sharedItems.mainQuoteController=self.quoteController

        
        self.contentViewController?.representedObject=sharedItems
        self.window?.delegate=NSApp.delegate as? AppDelegate
    }
    
    
    //TODO:
    //- (void)awakeFromNib {
//    [super awakeFromNib];
//    if (! self.representedObject) {
//    self.representedObject = <your_model_object>;
//    }
//}
    
    
    //MARK: - Variables
    @objc var moc: NSManagedObjectContext = ((NSApp.delegate as? AppDelegate)?.managedObjectContext)!
    @IBOutlet var quoteController: NSArrayController!
    
}
