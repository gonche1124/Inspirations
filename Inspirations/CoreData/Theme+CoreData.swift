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