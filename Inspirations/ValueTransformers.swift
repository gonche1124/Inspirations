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

//String to Upper case for Left Controller.
class StringToUpperCase: ValueTransformer{
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let stringValue = value as? String else {return value}
        return stringValue.uppercased()
    }
}


//Tooltip for CocoaBindings table.
class SetToCompoundString: ValueTransformer {
    
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let valueSet = value as? Set<Tags> else {return nil}
//        return valueSet.map({$0.tagName!}).joined(separator: "\n")
//    }
}

//Collection count because bindings is not working. /Playist View
class SetToCount: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let valueSet = value as? NSSet else {return nil}
        return "\(valueSet.count)"
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

//NSAttributed String to normal string.
class AttributedStringToString: ValueTransformer{
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let simpleString = value as? NSAttributedString else {return nil}
        return simpleString.string
    }
}

