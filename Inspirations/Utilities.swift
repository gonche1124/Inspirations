//
//  Utilities.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/14/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa

// MARK: - Value Transformers
//Collection count becasue bindings is not working.
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

//MARK: - NSTreeNodeExtension
extension NSTreeNode {
    //Checks if is Leaf in Themes controller
    func isTheme()->Bool{
        return ((self.representedObject as! NSManagedObject).className == "Theme")
    }
    
    //Checks if is Leaf in Themes controller
    func isAuthor()->Bool{
        return ((self.representedObject as! NSManagedObject).className == "Author")
    }
}

//MARK: - NSManagedObject extensions
extension NSManagedObject {
    
    var isLeafQuote: Bool {get {return self.className == "Quote"}} //Used in NSTreeController
    
    var sortingKey:String {get {
        switch self.className {
        case "Quote":
            return (self as! Quote).quote!
        case "Author":
            return (self as! Author).name!
        case "Theme":
            return (self as! Theme).topic!
        default:
            return ""
        }
        }}

}

//MARK: - NSDialog
extension NSAlert {
    
    static func showAlert(title: String?, message: String?, style: NSAlert.Style = .critical, withOk: Bool=true, andCancel:Bool=true) -> NSAlert {
        let alert = NSAlert()
        if let title = title {alert.messageText = title}
        if let message = message {alert.informativeText = message}
        if withOk {alert.addButton(withTitle: "Ok")}
        if andCancel {alert.addButton(withTitle: "Cancel")}
        alert.alertStyle = style

        return alert
    }
}



