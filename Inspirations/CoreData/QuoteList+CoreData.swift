//
//  QuoteList+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(QuoteList)
public class QuoteList: LibraryItem, Codable {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteList> {
        return NSFetchRequest<QuoteList>(entityName: "QuoteList")
    }
    
    //Keys
    enum CodingKeys:String, CodingKey{
        case isRootItem = "isRootItem"
        case isShown = "isShown"
        case libraryType = "libraryType"
        case name = "pName"
        case belongsToLibraryItem = "belongsToLibraryItem"
        case hasLibraryItems = "hasLibraryItems"
        case smartPredicate = "smartPredicate"
        case hasQuotes = "hasQuotes"
    }
    
    //Properties
    @NSManaged public var smartPredicate: NSObject?
    @NSManaged public var hasQuotes: NSSet?
    
    //Decodable
    public required convenience init(from decoder: Decoder) throws {
        
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedContext,
            let moc = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "QuoteList", in: moc) else {
                fatalError("Failed to decode QuoteList")}
        //TODO: Implement way to capture when lists are called same as default lists i.e. Favorites, Library
        self.init(entity: entity, insertInto: moc)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isRootItem = false
        self.isShown = true
        self.libraryType = LibraryType.list.rawValue
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.belongsToLibraryItem = LibraryItem.getRootItem(withName: "Lists", inContext: moc)

    }
    
    
    //Codable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .isRootItem)
        try container.encode(isShown, forKey: .isShown)
        try container.encode(libraryType, forKey: .libraryType)
        try container.encode(name, forKey: .name)
    }
}

// MARK: Generated accessors for hasQuotes
extension QuoteList {
    
    @objc(addHasQuotesObject:)
    @NSManaged public func addToHasQuotes(_ value: Quote)
    
    @objc(removeHasQuotesObject:)
    @NSManaged public func removeFromHasQuotes(_ value: Quote)
    
    @objc(addHasQuotes:)
    @NSManaged public func addToHasQuotes(_ values: NSSet)
    
    @objc(removeHasQuotes:)
    @NSManaged public func removeFromHasQuotes(_ values: NSSet)
    
}
