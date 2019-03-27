//
//  Theme+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(Theme)
public class Theme: NSManagedObject{
    
    //Properties
    @NSManaged public var themeName: String?
    @NSManaged public var hasQuotes: NSSet?
    @NSManaged public var createdAt:NSDate
    @NSManaged public var updatedAt:NSDate
    
    //Convinience Init.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Theme", in: moc) else {
            fatalError("Failed to decode Author")}
        
        self.init(entity: entity, insertInto: moc)
        if let topicName = dictionary["themeName"] as? String{
            self.themeName=topicName
        }
    }
    
    //Required init for CoreDataUtilities.
    required public convenience init(named:String, in context:NSManagedObjectContext) {
        if named.trimWhites().isEmpty {
            fatalError("Failed to create Theme, name is empty.")
        }
        self.init(context: context)
        self.themeName=named
    }
    
    /// Returns the predicate used to search for quotes.
    var quotePredicate:NSPredicate {
        return NSPredicate(format: "isAbout.themeName contains [CD] %@", self.themeName!)
    }
}

//MARK: - Overrides
extension Theme {
    override public func validateForUpdate() throws {
        if self.hasQuotes?.count==0 {
            self.managedObjectContext?.delete(self)
        }
    }
    
    override public func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "createdAt")
        setPrimitiveValue(NSDate(), forKey: "updatedAt")
    }
    
    override public func willSave() {
        if self.updatedAt.timeIntervalSinceNow>10.0 {
            setPrimitiveValue(NSDate(), forKey: "updatedAt")
        }
    }
}

extension Theme:CoreDataUtilities{
    public static func createWithName(name: String, in context: NSManagedObjectContext) -> Theme {
        return Theme(named: name, in: context)
    }
}

extension Theme:Encodable{
    
    enum CodingKeys: String, CodingKey {
        case themeName
    }
    
    //Encodes the instance into JSON.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(themeName, forKey: .themeName)
    }
}

// MARK: - Generated accessors for hasQuotes
extension Theme {
    
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
extension Theme:ManagesQuotes{
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
