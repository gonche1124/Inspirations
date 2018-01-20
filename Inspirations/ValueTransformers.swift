//
//  ValueTransformers.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 1/14/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import Cocoa

// MARK: - Value Transformers

//Tooltip for plain table.
class SetToCompoundString: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let valueSet = value as? Set<Tags> else {return nil}
        return valueSet.map({$0.tag!}).joined(separator: "\n")
    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {return false}
}

//Collection count becasue bindings is not working. /Playist View
class SetToCount: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let valueSet = value as? NSSet else {return nil}
        return "\(valueSet.count)"
    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
}

//Heart transformer to image.
class BooleanToImage: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSImage.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let bValue = value as? Bool else {return nil}
        return NSImage.init(imageLiteralResourceName: bValue ? "red heart":"grey heart")

    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {
        return false
    }

}

//Heart transformer to image.
class stringToImage: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSImage.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let imgName = value as? String else {return nil}
        return NSImage(named: NSImage.Name(imgName))
    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
}

//Token field converter.
class SetToArray: ValueTransformer {
    override class func transformedValueClass() -> AnyClass{
        return NSArray.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let nsmoSet = value as? Set<NSManagedObject> else {return nil}
        return Array(nsmoSet)
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [NSManagedObject] else { return nil }
        return Set(array)
    }
    
}

//General collection to count.
class CollectionToCount: ValueTransformer{
    
    override  func transformedValue(_ value: Any?) -> Any? {
        guard let oneManagedObject = value as? [NSManagedObject] else {return nil}
        return oneManagedObject.count
    }
    
}

