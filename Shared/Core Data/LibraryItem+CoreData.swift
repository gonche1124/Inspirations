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
            return try? Quote.count(in: self.managedObjectContext!)
        case .favorites:
            return try? Quote.count(in: self.managedObjectContext!, with: NSPredicate.favoriteItems)
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
    
    //MARK: - Convinience init
    
    ///Creates a standard object.
    /// - parameter rootnamed: name of the root object.
    /// - parameter andType: Library Type of the standard object.
    /// - parameter inMOC: NSManagedObjectContext used too init the new Core Data Entity
    /// - Note: The library Type has to be one of the standard objects, otherwise it will throw an error.
    convenience init(standardType type:LibraryType, inMOC:NSManagedObjectContext){
        if !LibraryType.standardItems.contains(type) {
                fatalError("Failed to create LibraryItem")
        }
        self.init(context: inMOC)
        self.libraryType=type
        switch type {
        //TODO: Make it localizable.
        case .rootMain:
            self.name = "Main"
            self.sortingOrder="0"
        case .rootTag:
            self.name = "Tags"
            self.sortingOrder="1"
        case .rootList:
            self.name = "Lists"
            self.sortingOrder="2"
        case .rootLanguage:
            self.name = "Languauges"
            self.sortingOrder="3"
        case .mainLibrary:
            self.name = "Library"
            self.sortingOrder="0"
        case .favorites:
            self.name = "Favorites"
            self.sortingOrder="1"
        default:
            break
        }
        if [LibraryType.favorites, LibraryType.mainLibrary].contains(type){
            self.isRootItem=false
            self.belongsToLibraryItem=inMOC.get(standardItem: .rootMain)
        }
    }
    
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
    
    /// Initializer based on the name.
    required public convenience init(named:String, in context:NSManagedObjectContext) {
        if named.trimWhites().isEmpty {
            fatalError("Failed to create, name is empty.")
        }
        print("INIT CALLED FROM LIBRARYITEM")
        self.init(context: context)
        self.name=named
    }
}

extension LibraryItem:CoreDataUtilities{
    public static func createWithName(name: String, in context: NSManagedObjectContext) -> LibraryItem {
        return CoreEntity(named: name, in: context)
    }
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

