//
//  Author+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(Author)
public class Author: NSManagedObject, Codable {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }
    
    //Keys
    private enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
    //properties
    @NSManaged public var name: String?
    @NSManaged public var hasSaid: Set<Quote>? //was a NSSet
    
    //Decodable
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedContext,
            let moc = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Author", in: moc) else {
                fatalError("Failed to decode Author")}
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(entity:  entity, insertInto: moc)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    //Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    //Convinience Init.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Author", in: moc) else {
            fatalError("Failed to decode Author")}
        
        self.init(entity: entity, insertInto: moc)
        if let authorName = dictionary["name"] as? String{
            self.name=authorName
        }
    }
}

//MARK: - Others
extension Author {
    override public func validateForUpdate() throws {
        if self.hasSaid?.count==0 {
            self.managedObjectContext?.delete(self) //TODO: Potential bug.
        }
    }
}

// MARK: - Generated accessors for hasSaid
extension Author {
    
    @objc(addHasSaidObject:)
    @NSManaged public func addToHasSaid(_ value: Quote)
    
    @objc(removeHasSaidObject:)
    @NSManaged public func removeFromHasSaid(_ value: Quote)
    
    @objc(addHasSaid:)
    @NSManaged public func addToHasSaid(_ values: NSSet)
    
    @objc(removeHasSaid:)
    @NSManaged public func removeFromHasSaid(_ values: NSSet)
    
}

//MARK: - Protocols:
extension Author:ManagesQuotes{
    func containsQuotes() -> [Quote] {
        return Array(self.hasSaid!) 
    }
    func addQuote(quote: Quote) {
        self.addToHasSaid(quote)
    }
    func addQuotes(quotes: [Quote]) {
        self.addToHasSaid(NSSet.init(array: quotes))
    }
    func removeQuote(quote:Quote){
        self.removeFromHasSaid(quote)
    }
    func removeQuotes(quote:[Quote]){
        self.removeFromHasSaid(NSSet.init(array: quote))
    }
}
