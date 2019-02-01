//
//  LibraryItem+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(LibraryItem)
public class LibraryItem: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LibraryItem> {
        return NSFetchRequest<LibraryItem>(entityName: "LibraryItem")
    }
    
    //Properties
    @NSManaged public var isRootItem: Bool
    @NSManaged private var libraryTypeValue: String
    @NSManaged public var name: String
    @NSManaged public var belongsToLibraryItem: LibraryItem?
    @NSManaged public var hasLibraryItems: NSOrderedSet? //Set<LibraryItem>//NSOrderedSet?
    @NSManaged public var sortingOrder:String?
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt:NSDate
    
    /// LibraryType through a ENUM.
    var libraryType:LibraryType{
        get{
            return  self.rawValueForKey(key: "libraryTypeValue")! as LibraryType
        }
        set{
            self.setRawValue(value: newValue, forKey: "libraryTypeValue")
        }
    }
    
    //MARK: - Computed properties
    //Total Quotes the current item holds.
    var totalQuotes:Int?{
        switch self.libraryType {
        case .mainLibrary:
            return self.managedObjectContext?.count(ofEntity: .quote)
        case .favorites:
            return self.managedObjectContext?.count(ofEntity: .quote, with: NSPredicate.favoriteItems)
        default:
            return nil
        }
    }
    
    //MARK: - Overrides
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(NSDate(), forKey: "createdAt")
        setPrimitiveValue(NSDate(), forKey: "updatedAt")
        setPrimitiveValue(true, forKey: "isRootItem")
    }
    
    override public func willSave() {
        if self.updatedAt.timeIntervalSinceNow>10.0 {
            setPrimitiveValue(NSDate(), forKey: "updatedAt")
        }
    }

    
    //Decodable
//    public required convenience init(from decoder: Decoder) throws {
//
//        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedContext,
//            let moc = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
//            let entity = NSEntityDescription.entity(forEntityName: "LibraryItem", in: moc) else {
//                fatalError("Failed to decode LibraryItem")}
//
//        //try super.init(from: decoder)
//
//        self.init(entity: entity, insertInto: moc)
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.isRootItem = false //try container.decodeIfPresent(Bool.self, forKey: .isRootItem)
//        self.isShown = false //try container.decodeIfPresent(Bool.self, forKey: .isShown)
//        self.libraryType = try container.decodeIfPresent(String.self, forKey: .libraryType)
//        self.name = try container.decodeIfPresent(String.self, forKey: .name)
//        self.belongsToLibraryItem = try container.decodeIfPresent(LibraryItem.self, forKey: .belongsToLibraryItem)
////        if let itemsToAdd = try container.decodeIfPresent([hasLibraryItems].self, forKey: .hasLibraryItems){
////            self.addToHasLibraryItems(itemsToAdd)
////        }
//
//    }
    
    //Encode
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//
//    }
    
    //MARK: - Convinience init
    
    ///Creates a root object.
    /// - parameter rootnamed: name of the root object.
    /// - parameter andType: Library Type of the root object.
    /// - parameter inMOC: NSManagedObjectContext used too init the new Core Data Entity
    /// - Note: The library Type has to be one of the root objects, otherwise it will throw an error.
    convenience init(standardNamed:String, andType type:LibraryType, inMOC:NSManagedObjectContext){
        guard let entity = NSEntityDescription.entity(forEntityName: "LibraryItem", in: inMOC),
            standardNamed != "", LibraryType.standardItems.contains(type) else {
                fatalError("Failed to create LibraryItem")
        }
        
        self.init(entity: entity, insertInto: inMOC)
        self.name=standardNamed
        self.libraryType=type
        switch type {
        case .rootMain:
            self.sortingOrder="0"
        case .rootTag:
            self.sortingOrder="1"
        case .rootList:
            self.sortingOrder="2"
        case .rootLanguage:
            self.sortingOrder="3"
        case .mainLibrary:
            self.sortingOrder="0"
        case .favorites:
            self.sortingOrder="1"
        default:
            self.sortingOrder=standardNamed
        }
        if [LibraryType.favorites, LibraryType.mainLibrary].contains(type){
            self.isRootItem=false
            self.belongsToLibraryItem=inMOC.get(LibraryItem: .rootMain)
        }
    }
    
    //TODO: ERASE OR FIX IT!
//    public convenience init?(inMOC:NSManagedObjectContext, andName:String, isRoot:Bool){
//        guard let entity = NSEntityDescription.entity(forEntityName: "LibraryItem", in: inMOC),
//            andName != "" else {
//                fatalError("Failed to create LibraryItem")}
//
//        self.init(entity: entity, insertInto: inMOC)
//        //self.libraryType = .rootItem
//        self.name=andName
//        self.isRootItem=isRoot
//        if !isRoot{
//        self.belongsToLibraryItem = LibraryItem.getRootItem(named: "Library", , ofType:inContext: inMOC)
//        }
//    }
    
    /// Convinience Init to create an item with a given name, in the specified context and
    /// assigning itself as child of underItem.
    /// - parameter inContext: NSManagedContext to create the Entity
    /// - parameter named: name to assign the new entity created.
    /// - parameter underItem: CoreData entity to use as it´s parent for the relationship.
    /// - parameter ofType: type of item to create.
    public convenience init?(named:String, ofType type:LibraryType, underItem:LibraryItem, inContext moc:NSManagedObjectContext){
        
        self.init(context: moc)
        self.libraryType=type
        self.isRootItem=false
        self.belongsToLibraryItem=underItem
        self.name=named
        self.sortingOrder=named
    }
    
//    /// Convinience Init to create a folder with a given name, in the specified context and
//    /// assigning itself as child of underItem.
//    /// - parameter inMoc: NSManagedContext to create the Entity
//    /// - parameter folderNamed: name to assign the new entity created.
//    /// - parameter underItem: CoreData entity to use as it´s parent for the relationship.
//    public convenience init?(folderNamed:String,inMoc:NSManagedObjectContext, underItem:LibraryItem){
//        guard let entity = NSEntityDescription.entity(forEntityName: "LibraryItem", in: inMoc),
//            folderNamed != "" else {
//                fatalError("Failed to create LibraryItem")}
//
//        self.init(entity: entity, insertInto: inMoc)
//        self.libraryType = .folder
//        self.name=folderNamed
//        self.isRootItem=false
//        self.belongsToLibraryItem=underItem
//        self.sortingOrder=folderNamed
//    }
    
    //Prints the description
//    override open var description: String{
//        let dict = self.entity.rel
//        return "AA\nBB"
//    }
    
}

// MARK: - Generated accessors for hasLibraryItems
extension LibraryItem {
    
    @objc(insertObject:inHasLibraryItemsAtIndex:)
    @NSManaged public func insertIntoHasLibraryItems(_ value: LibraryItem, at idx: Int)
    
    @objc(removeObjectFromHasLibraryItemsAtIndex:)
    @NSManaged public func removeFromHasLibraryItems(at idx: Int)
    
    @objc(insertHasLibraryItems:atIndexes:)
    @NSManaged public func insertIntoHasLibraryItems(_ values: [LibraryItem], at indexes: NSIndexSet)
    
    @objc(removeHasLibraryItemsAtIndexes:)
    @NSManaged public func removeFromHasLibraryItems(at indexes: NSIndexSet)
    
    @objc(replaceObjectInHasLibraryItemsAtIndex:withObject:)
    @NSManaged public func replaceHasLibraryItems(at idx: Int, with value: LibraryItem)
    
    @objc(replaceHasLibraryItemsAtIndexes:withHasLibraryItems:)
    @NSManaged public func replaceHasLibraryItems(at indexes: NSIndexSet, with values: [LibraryItem])
    
    @objc(addHasLibraryItemsObject:)
    @NSManaged public func addToHasLibraryItems(_ value: LibraryItem)
    
    @objc(removeHasLibraryItemsObject:)
    @NSManaged public func removeFromHasLibraryItems(_ value: LibraryItem)
    
    @objc(addHasLibraryItems:)
    @NSManaged public func addToHasLibraryItems(_ values: NSOrderedSet)
    
    @objc(removeHasLibraryItems:)
    @NSManaged public func removeFromHasLibraryItems(_ values: NSOrderedSet)
    
}

