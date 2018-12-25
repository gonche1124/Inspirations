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
    @NSManaged public var smartPredicate: NSPredicate?
    @NSManaged public var hasQuotes: NSSet?
    
    ///Computed properties used in the left controller.
    override var totalQuotes:Int?{
        if let predicate=smartPredicate{
            return self.managedObjectContext?.count(ofEntity: Entities.quote.rawValue, with: predicate)
        }
        return hasQuotes?.count
    }
    
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
    
    //Convinience init
    public convenience init?(inMOC:NSManagedObjectContext, andName:String, withSmartList:NSPredicate?=nil){
        guard let entity = NSEntityDescription.entity(forEntityName: "QuoteList", in: inMOC),
            andName != "" else {
                fatalError("Failed to create Quote List")}
        //TODO: Handle case when it is a folder instead of a list.
        self.init(entity: entity, insertInto: inMOC)
        self.libraryType = LibraryType.list.rawValue
        self.name=andName
        self.isShown=true
        self.isRootItem=false
        self.belongsToLibraryItem = LibraryItem.getRootItem(withName: "Lists", inContext: inMOC)
        if (withSmartList != nil)  {
            self.smartPredicate=withSmartList
            self.libraryType=LibraryType.smartList.rawValue
        }
    }
    
    //Convinience Init.
    public convenience init?(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let listName = dictionary["name"] as? String else {
            fatalError("Failed to create Quote List")}
        self.init(inMOC: moc, andName: listName)
    }

}

// MARK: - Generated accessors for hasQuotes
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

//MARK: - Protocols:
extension QuoteList:ManagesQuotes{
    func containsQuotes() -> [Quote] {
        return Array(self.hasQuotes!) as! [Quote]
    }
    
    func addQuote(quote: Quote) {
        self.addToHasQuotes(quote)
    }
    
    func addQuotes(quotes: [Quote]) {
        self.addToHasQuotes(NSSet.init(array: quotes))
    }
    func removeQuote(quote:Quote){
        self.removeFromHasQuotes(quote)
    }
    func removeQuotes(quote:[Quote]){
        self.removeFromHasQuotes(NSSet.init(array: quote))
    }
}
