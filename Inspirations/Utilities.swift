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
    
    //Used to sort elements.
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
    
    //Easy way to minimize boilerplate code.
    class func firstWith(predicate:NSPredicate, inContext:NSManagedObjectContext)->NSManagedObject?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.className())
        request.predicate=predicate
        request.fetchLimit=1
        
        guard let results = try! inContext.fetch(request).first as? NSManagedObject else {return nil}
        return results
    }

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

//MARK: - NSViewController
extension NSViewController{
    
    var mainToolbarItems: Array<NSToolbarItem>?  {return (NSApp.mainWindow?.toolbar?.items) ?? nil} //Easy access to toolbar
    
    var moc: NSManagedObjectContext {return (NSApp.delegate as! AppDelegate).managedObjectContext} //easy access to moc.
    
    //Dictionary to bind searchfield to array controller
    func searchBindingDictionary(withName title:String="Quote", andPredicate predicate:String="quote CONTAINS[cd] $value")-> [NSBindingOption:Any]{
        let mainDictionary=[NSBindingOption(rawValue: "NSDisplayName"):title,
                            NSBindingOption(rawValue: "NSPredicateFormat"):predicate,
                            NSBindingOption(rawValue: "NSValidatesImmediately"):0,
                            NSBindingOption(rawValue: "NSRaisesForNotApplicableKeys"):1] as [NSBindingOption : Any]
        return mainDictionary
    }
}

