//
//  Theme+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

//TODO: Transofmr Codable to Encodable and cleanup code.
@objc(Theme)
public class Theme: NSManagedObject{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Theme> {
        return NSFetchRequest<Theme>(entityName: "Theme")
    }
    
    //Coding keys
    private enum CodingKeys: String, CodingKey{
        case themeName = "topic"
    }
    
    //Properties
    @NSManaged public var themeName: String?
    @NSManaged public var hasQuotes: NSSet?
    @NSManaged public var createdAt:NSDate
    @NSManaged public var updatedAt:NSDate
    
    //Overrides
    override public func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "createdAt")
        setPrimitiveValue(NSDate(), forKey: "updatedAt")
    }
    
    override public func willSave() {
        if self.updatedAt.timeIntervalSinceNow>10.0 {
            setPrimitiveValue(NSDate(), forKey: "updatedAt")
        }
//        if let updatedAt = self.updatedAt {
//            if updatedAt.timeIntervalSince(Date()) > 10.0 {
//                setPrimitiveValue(NSDate(), forKey: "updatedAt")
//                //self.updatedAt = NSDate()
//            }
//
//        } else {
//            setPrimitiveValue(NSDate(), forKey: "updatedAt")
//            //self.updatedAt = NSDate()
//        }
    }
    
    
    //Convinience Init.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Theme", in: moc) else {
            fatalError("Failed to decode Author")}
        
        self.init(entity: entity, insertInto: moc)
        if let topicName = dictionary["themeName"] as? String{
            self.themeName=topicName
        }
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

//MARK: - Others
extension Theme {
    override public func validateForUpdate() throws {
        if self.hasQuotes?.count==0 {
            self.managedObjectContext?.delete(self)
        }
    }
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
