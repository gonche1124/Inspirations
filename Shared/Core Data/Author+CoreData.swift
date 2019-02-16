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
public class Author: NSManagedObject {
    
    //properties
    @NSManaged public var name: String?
    @NSManaged public var hasSaid: Set<Quote>? //was a NSSet
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt:NSDate
    
    //MARK: - Initializers.
    ///Convinience Init based on dictionary andused in JSON import.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Author", in: moc) else {
            fatalError("Failed to decode Author")}
        
        self.init(entity: entity, insertInto: moc)
        if let authorName = dictionary["name"] as? String{
            self.name=authorName
        }
    }
    
    /// Initializer based on the name.
    required public convenience init(named:String, in context:NSManagedObjectContext) {
        if named.trimWhites().isEmpty {
            fatalError("Failed to create Author, name is empty.")
        }
        self.init(context: context)
        self.name=named
    }
}

//FOC extension.
extension Author:CoreDataUtilities{
    public static func createWithName(name: String, in context: NSManagedObjectContext) -> Author {
        return Author(named: name, in: context)
    }
}


//MARK: - Overrides
extension Author {
    
    //Called when changing.
    override public func validateForUpdate() throws {
        try super.validateForUpdate()
        if self.hasSaid?.count==0 {
            self.managedObjectContext?.delete(self) //TODO: Potential bug.
        }
    }
    
    //Called when inserting.
    override public func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "createdAt")
        setPrimitiveValue(NSDate(), forKey: "updatedAt")
    }
    
    //Called when saving.
    override public func willSave() {
        if self.updatedAt.timeIntervalSinceNow>10.0 {
            setPrimitiveValue(NSDate(), forKey: "updatedAt")
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
