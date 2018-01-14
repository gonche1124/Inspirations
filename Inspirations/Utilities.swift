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
        
//        if value == nil {
//            return nil
//        }else {
//            return NSImage.init(imageLiteralResourceName: (value as! Bool) ? "red heart":"grey heart")
//        }
    }
    
    //No Reverse.
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        print (value)
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
extension NSViewController {
    
    var mainToolbarItems: Array<NSToolbarItem>?  {return (NSApp.mainWindow?.toolbar?.items) ?? nil} //Easy access to toolbar
    
    var moc: NSManagedObjectContext {return (NSApp.delegate as! AppDelegate).managedObjectContext} //easy access to moc.
    
    var mainSearchField: NSView? {return ((self.mainToolbarItems?.first(where: {$0.itemIdentifier.rawValue=="searchToolItem"})?.view) ?? nil)!} //Easy access to searchtoolbar
    //TODO: Giving errors
    //WARNING
    
    //Dictionary to bind searchfield to array controller
    func searchBindingDictionary(withName title:String="Quote", andPredicate predicate:String="quote CONTAINS[cd] $value")-> [NSBindingOption:Any]{
        let mainDictionary=[NSBindingOption(rawValue: "NSDisplayName"):title,
                            NSBindingOption(rawValue: "NSPredicateFormat"):predicate,
                            NSBindingOption(rawValue: "NSValidatesImmediately"):0,
                            NSBindingOption(rawValue: "NSRaisesForNotApplicableKeys"):1] as [NSBindingOption : Any]
        return mainDictionary
    }
    
    //Set up search field
    func bind(searchField: NSSearchField, toQuoteController controller: NSArrayController){
        //Get dictionaries
        let dQuotes = self.searchBindingDictionary(withName: "Quote", andPredicate: "quote CONTAINS[cd] $value")
        let dAuthor = self.searchBindingDictionary(withName: "Author", andPredicate: "fromAuthor.name CONTAINS[cd] $value")
        let dThemes = self.searchBindingDictionary(withName: "Themes", andPredicate: "isAbout.topic CONTAINS[cd] $value")
        let dTags = self.searchBindingDictionary(withName: "Tags", andPredicate: "tags.tag CONTAINS[cd] $value")
        let dAll = self.searchBindingDictionary(withName: "All", andPredicate: "(quote CONTAINS[cd] $value) OR (fromAuthor.name CONTAINS[cd] $value) OR (isAbout.topic CONTAINS[cd] $value) OR (tags.tag CONTAINS[cd] $value)")
        //Set up bindings
        searchField.bind(.predicate, to: controller, withKeyPath: "filterPredicate", options:dAll)
        searchField.bind(NSBindingName("predicate2"), to: controller, withKeyPath: "filterPredicate", options:dAuthor)
        searchField.bind(NSBindingName("predicate3"), to: controller, withKeyPath: "filterPredicate", options:dQuotes)
        searchField.bind(NSBindingName("predicate4"), to: controller, withKeyPath: "filterPredicate", options:dThemes)
        searchField.bind(NSBindingName("predicate5"), to: controller, withKeyPath: "filterPredicate", options:dTags)
    }

    //Set up infoLabel
    func bind(infoLabel:NSTextField, toQuotes qc:NSArrayController, andAuthor ac:NSArrayController, andThemes tc:NSArrayController){
        
        let displayP = "%{value1}@ of %{value2}@ Selected, %{value3}@ authors, %{value4}@ Topics"
        
        infoLabel.bind(NSBindingName("displayPatternValue1"), to: qc, withKeyPath: "selection.@count", options: [NSBindingOption(rawValue: "NSDisplayPattern"):displayP])
        infoLabel.bind(NSBindingName("displayPatternValue2"), to: qc, withKeyPath: "arrangedObjects.@count", options: [NSBindingOption(rawValue: "NSDisplayPattern"):displayP])
        infoLabel.bind(NSBindingName("displayPatternValue3"), to: ac, withKeyPath: "arrangedObjects.@count", options:[NSBindingOption(rawValue: "NSDisplayPattern"):displayP])
        infoLabel.bind(NSBindingName("displayPatternValue4"), to: tc, withKeyPath: "arrangedObjects.@count", options:[NSBindingOption(rawValue: "NSDisplayPattern"):displayP])
        
    }


}



//Protocols for controllers of tabView
@objc protocol ControllerProtocol{
    @objc optional var currentQuoteController: NSArrayController? {get} //optional variables.
    @objc optional var currentAuthorController: NSArrayController? {get}
    @objc optional var currentThemesController: NSArrayController? {get}
    @objc optional var currentTagsController: NSArrayController? {get}
}

//Protocol for main controller
protocol mainViewController{
    var selectedQuoteController: NSArrayController {get}
    var selectedAuthorController: NSArrayController {get}
}

extension NSViewController: ControllerProtocol {
    var currentQuoteController: NSArrayController?{
        switch self.className {
        case "CocoaBindingsTable":
            return (self as! CocoaBindingsTable).quotesArrayController
        case "QuoteController":
            return (self as! QuoteController).quotesArray
        case "BigViewController":
            return (self as! BigViewController).arrayController
        default:
            return nil
        }
    }
}



