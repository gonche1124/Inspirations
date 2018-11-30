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

//Tooltip for CocoaBindings table.
class SetToCompoundString: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let valueSet = value as? Set<LibraryItem> else {return nil}
        return valueSet.map({$0.name!}).joined(separator: "\n")
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

//NStokenField Transformer
class EntityToToken:ValueTransformer{
    //Transform value
    override  func transformedValue(_ value: Any?) -> Any? {
        guard let theTags = value as? Set<Tag> else {return nil}
        return Array(theTags)
        //return theTags.map({$0.name!}).joined(separator: ",")
    }
    
    override class func allowsReverseTransformation()->Bool{return true}

}


