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
public class Theme: NSManagedObject, Codable{
    
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
    
    //Decodable
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedContext,
            let moc = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Theme", in: moc) else {
                fatalError("Failed to decode Theme")}
        
        self.init(entity: entity, insertInto: moc)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.themeName = try container.decodeIfPresent(String.self, forKey: .themeName)
    }
    
    //Codable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(themeName, forKey: .themeName)
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
