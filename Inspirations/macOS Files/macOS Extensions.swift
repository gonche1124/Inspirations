//
//  macOS Extensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import AppKit


//MARK: -
extension NSUserInterfaceItemIdentifier {
    static let dataCell = NSUserInterfaceItemIdentifier.init("DataCell")
    static let headerCell = NSUserInterfaceItemIdentifier.init("noImage")
    //static let headerCell = NSUserInterfaceItemIdentifier.init("HeaderCell")
}

//MARK: -
//Extension to array of items where elements conform to protocol identifier.
extension Array where Element:NSUserInterfaceItemIdentification{
    func firstWith(identifier:String)->Element?{
        guard let item=self.first(where:{$0.identifier?.rawValue==identifier}) else {return nil}
        return item
    }
}


//MARK: -
extension NSMenu{
    
    ///Less verbose to create nsmenuItem with a specified identifier
    func addMenuItem(title:String, action: Selector?, keyEquivalent:String, identifier:String ){
        let newItem = NSMenuItem.init(title: title, action: action, keyEquivalent:keyEquivalent)
        newItem.identifier=NSUserInterfaceItemIdentifier(rawValue: identifier)
        self.addItem(newItem)
    }
    
    ///Easy way to fecth item with identifier
    func item(withIdentifier:String)->NSMenuItem?{
        return self.items.firstWith(identifier: withIdentifier)
        //return self.items.first(where: {$0.identifier!.rawValue==withIdentifier})
    }
}

//MARK: -
extension NSTextField{
    //Used fo validation in the UI/ADD to make sure it has a value.
    @objc dynamic var hasValue:Bool{
        get {
            print("Value: \(self.stringValue)")
            let myCharacters=CharacterSet.letters.inverted
            return !self.stringValue.trimmingCharacters(in: myCharacters).isEmpty
        }
    }
    
    
}

//MARK: -
extension NSViewController{
    ///easy access to persistentStore
    var pContainer:NSPersistentContainer{
        return (NSApp.delegate as! AppDelegate).persistentContainer
    }
    
    ///easy access to managed object context.
    @objc dynamic var moc: NSManagedObjectContext {return (NSApp.delegate as! AppDelegate).managedObjectContext}
    
    ///easy access to a background managed object context.
    @objc dynamic var mocBackground: NSManagedObjectContext {
        let tempMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempMoc.parent=self.moc
        return tempMoc
    }
    
    ///Simplifications of do-try-save block.
    func saveMainContext(){
        do { try self.moc.save()} catch  {
            print(error)
        }
    }
    ///Simplifications of do-try-save block (for background thread)
    func saveBackgroundContext(){
        do { try self.mocBackground.save()} catch  {
            print(error)
        }
    }
}

//MARK: -
extension NSAlert{
    convenience init(totalItems:Int, isDeleting:Bool) {
        self.init()
        self.messageText = isDeleting ? "Deletes Records":"Removes Records"
        self.addButton(withTitle: "OK")
        self.addButton(withTitle: "Cancel")
        self.informativeText = "Are you sure you want to " + (isDeleting ? "delete":"remove") + " the \(totalItems) selected Quotes?"
        self.alertStyle = .warning
    }
    
    convenience init(withPopUpFrom:Array<String>, forItem:String, at:Int, of:Int){
        self.init()
        self.messageText="Map the key \(at) of \(of)"
        self.informativeText="Please select the key that should be used to assign the value of: \n\(forItem)"
        self.alertStyle = .informational
        self.addButton(withTitle: "OK")
        self.addButton(withTitle: "Cancel")
        self.showsSuppressionButton=true
        self.suppressionButton?.title="Ignore future keys"
        //Layout:
        let keyPopUp=NSPopUpButton.init(title: "Ignore...", target: nil, action: nil)
        keyPopUp.addItems(withTitles: withPopUpFrom)
        keyPopUp.frame=NSRect(origin: keyPopUp.frame.origin, size: CGSize(width: 200, height: keyPopUp.frame.height))
        //keyPopUp.setNeedsDisplay()
        keyPopUp.needsDisplay=true
        self.accessoryView=keyPopUp
    }
}

//MARK: -
extension NSView{
    ///Recursevely get all views
    func getAllSubViews<T:NSView>()->[T]{
        var subviews=[T]()
        self.subviews.forEach { subview in
            subviews += subview.getAllSubViews() as [T]
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }
    
    //Set background color in interface without subclassing.
    @IBInspectable
    var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

//MARK: - NSPredicateEditorRowTemplate
extension NSPredicateEditorRowTemplate {
    
    ///Constants
    static let numberOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .greaterThan, .greaterThanOrEqualTo, .lessThan, .lessThanOrEqualTo]
    static let stringOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .beginsWith, .endsWith, .matches, .like]
    static let boolOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]
    static let dateOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .greaterThan, .lessThan]
    
    
    ///Compound convinince initalizer.
    convenience init(compoundTypes: [NSCompoundPredicate.LogicalType] ) {
        let compoundTypesNSNumber = compoundTypes.map{NSNumber(value: $0.rawValue)}
        self.init( compoundTypes: compoundTypesNSNumber )
    }
    
    /// Initializes row templates from a core data entity.
    static func templates(forEntity entity:String, in moc:NSManagedObjectContext, includingRelationships:Bool=false, andPrefix:String="")->[NSPredicateEditorRowTemplate] {
        var templateRows=[NSPredicateEditorRowTemplate]()
        let entityDescription=NSEntityDescription.entity(forEntityName: entity, in: moc)
        let attDict = entityDescription?.attributesByNameForPredicateEditor
        attDict?.forEach{
            if let newRow=NSPredicateEditorRowTemplate.init(forKeysPath: $0.key, ofType: $0.value, andPrefix:andPrefix){
                templateRows.append(newRow)
            }
        }
        
        //Check for realtionships:
        if includingRelationships{
            let relationsNames = entityDescription?.relationshipsByNameForPredicateEditor
            relationsNames?.forEach{
                templateRows.append(contentsOf: NSPredicateEditorRowTemplate.templates(forEntity: $0.value!, in: moc, andPrefix:"\($0.key)."))
            }
            
        }
        return templateRows
    }
    
    /// Generic initializer for attribute types.
    /// - parameter keyPaths: key path to the attribute.
    /// - parameter ofType: type of attriniute stored.
    /// - parameter andPrefix: used for relationships.
    /// - Note: Used to simplify the creation of core data entities by calling this with the Core Data parameters.
    convenience init? (forKeysPath keyPaths:String, ofType type:NSAttributeType, andPrefix prefix:String=""){
        var templateOperator = [NSNumber]()
        
        //Setup depending on the type
        switch type {
    case .decimalAttributeType, .doubleAttributeType, .floatAttributeType, .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            templateOperator = NSPredicateEditorRowTemplate.numberOperators.map{NSNumber(value: $0.rawValue)}
        case .dateAttributeType:
            templateOperator = NSPredicateEditorRowTemplate.dateOperators.map{NSNumber(value: $0.rawValue)}
        case .stringAttributeType:
            templateOperator = NSPredicateEditorRowTemplate.stringOperators.map{NSNumber(value: $0.rawValue)}
        case .booleanAttributeType:
            templateOperator = NSPredicateEditorRowTemplate.boolOperators.map{NSNumber(value: $0.rawValue)}
        default:
            print("Attribute type: \(type) not implemented.")
            return nil
        }
        //Generic values
        let leftExp = NSExpression(forKeyPath: prefix+keyPaths)
        let options = type == .stringAttributeType ? (Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)):0
        self.init( leftExpressions: [leftExp],
                   rightExpressionAttributeType: type,
                   modifier: .direct,
                   operators: templateOperator,
                   options: options )
    }
}


