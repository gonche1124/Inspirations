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
    
    //Keys
    private enum CodingKeys:String, CodingKey{
        case isRootItem = "isRootItem"
        case isShown = "isShown"
        case libraryType = "libraryType"
        case name = "name"
        case belongsToLibraryItem = "belongsToLibraryItem"
        case hasLibraryItems = "hasLibraryItems"
    }
    
    //Properties
    @NSManaged public var isRootItem: Bool
    @NSManaged public var isShown: Bool
    @NSManaged public var libraryType: String?
    @NSManaged public var name: String?
    @NSManaged public var belongsToLibraryItem: LibraryItem?
    @NSManaged public var hasLibraryItems: NSOrderedSet? //Set<LibraryItem>//NSOrderedSet?
    
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
//        //TODO: Add other encoders.
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