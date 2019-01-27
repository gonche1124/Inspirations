//
//  Tag+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: LibraryItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    //Keys
    enum CodingKeys:String, CodingKey{
        case isRootItem = "isRootItem"
        case isShown = "isShown"
        case libraryTypeKey = "libraryType"
        case name = "name"
        case belongsToLibraryItem = "belongsToLibraryItem"
        case hasLibraryItems = "hasLibraryItems"
        case hasQuotes = "hasQuotes"
    }
    
    //Properties
    @NSManaged public var hasQuotes: NSSet?
    
    ///Computed properties used in the left controller.
    override var totalQuotes:Int?{
        return hasQuotes?.count
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.setPrimitiveValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
    }
    
    //Decodable
    public required convenience init(from decoder: Decoder) throws {
        
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedContext,
            let moc = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Tag", in: moc) else {
                fatalError("Failed to decode Tag")}
        
        self.init(entity: entity, insertInto: moc)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isRootItem = false
        self.isShown = true
        self.libraryType = .tag
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.belongsToLibraryItem = LibraryItem.getRootItem(withName: "Tags", inContext: moc)
        self.sortingOrder=self.name
        
    }
    
    //Codable
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(isRootItem, forKey: .isRootItem)
//        try container.encode(isShown, forKey: .isShown)
//        try container.encode(libraryType, forKey: .libraryType)
//        try container.encode(name, forKey: .name)
//    }
    
    //Convinience init.
    public convenience init?(inMOC:NSManagedObjectContext, andName:String){
        guard let entity = NSEntityDescription.entity(forEntityName: "Tag", in: inMOC),
        andName != "" else {
            fatalError("Failed to create Tag")}
        
        self.init(entity: entity, insertInto: inMOC)
        self.libraryType = .tag
        self.name=andName
        self.isShown=true
        self.isRootItem=false
        self.sortingOrder=self.name
        self.belongsToLibraryItem = LibraryItem.getRootItem(named: "Tags", , ofType:inContext: inMOC)
    }
    
    //Convinience Init.
    public convenience init?(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let name = dictionary["name"] as? String else {
            fatalError("Failed to decode Tag")}
        self.init(inMOC: moc, andName: name)
    }
    
}

// MARK: - Generated accessors for hasQuotes
extension Tag {
    
    @objc(addHasQuotesObject:)
    @NSManaged public func addToHasQuotes(_ value: Quote)
    
    @objc(removeHasQuotesObject:)
    @NSManaged public func removeFromHasQuotes(_ value: Quote)
    
    @objc(addHasQuotes:)
    @NSManaged public func addToHasQuotes(_ values: NSSet)
    
    @objc(removeHasQuotes:)
    @NSManaged public func removeFromHasQuotes(_ values: NSSet)
    
}

//MARK: - Others
extension Tag {
    override public func validateForUpdate() throws {
        if self.hasQuotes?.count==0 {
            self.managedObjectContext?.delete(self)
        }
    }
}

//MARK: - Protocols:
extension Tag:ManagesQuotes{
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
