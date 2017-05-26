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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Variables
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
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



