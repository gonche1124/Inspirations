//
//  Quote+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData
import Cocoa

@objc(Quote)
public class Quote: NSManagedObject, Codable{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quote> {
        return NSFetchRequest<Quote>(entityName: "Quote")
    }
    
    //Keys
    private enum CodingKeys: String, CodingKey {
        case isFavorite = "isFavorite"
        case quoteString = "quote"
        case totalLetters = "totalLetters"
        case totalWords = "totalWords"
        case from = "fromAuthor"
        case isAbout = "isAbout"
        case isIncludedIn = "inPlaylist"
        case isTaggedWith = "isTaggedWith"
        case spelledIn = "spelledIn"
    }
    
    //Check for custom initialization for dynamic keys.
    private enum myAlt:String, CodingKey{
        case quoting = "quote"
    }
    
    //Properties
    @NSManaged public var isFavorite: Bool
    @NSManaged public var quoteString: String?
    @NSManaged public var totalLetters: Int16
    @NSManaged public var totalWords: Int16
    @NSManaged public var from: Author?
    @NSManaged public var isAbout: Theme?
    @NSManaged public var isIncludedIn: QuoteList?
    @NSManaged public var isTaggedWith: NSSet?
    @NSManaged public var spelledIn: Language?
    
    //Decodable
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedContext,
            let moc = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Quote", in: moc) else {
                fatalError("Failed to decode Quote")}
        
        
        //https://stackoverflow.com/questions/35574928/update-change-the-rawvalue-of-a-enum-in-swift
        
        self.init(entity:  entity, insertInto: moc)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //self.isFavorite = (try container.decodeIfPresent(Bool.self, forKey: .isFavorite))! //What happens if is string/int?
        self.quoteString = try container.decode(String.self, forKey: .quoteString)
        self.from = try container.decode(Author.self, forKey: .from) //TODO: Make case for multiple keys.
        self.isAbout = try container.decode(Theme.self, forKey: .isAbout)
        
        //ProgressBar
        if let textField = decoder.userInfo[CodingUserInfoKey.progressText!] as? NSTextField,
            let totItems = decoder.codingPath.first?.intValue {
            DispatchQueue.main.async {
                textField.stringValue="Imported \(totItems) quotes"
            }

        }
    }
    
    //Encodable
    public func encode(to encoder: Encoder) throws {
        var containter = encoder.container(keyedBy: CodingKeys.self)
        try containter.encode(isFavorite, forKey: .isFavorite)
        try containter.encode(quoteString, forKey: .quoteString)
        try containter.encode(totalLetters, forKey: .totalLetters)
        try containter.encode(totalWords, forKey: .totalWords)
        try containter.encode(from, forKey: .from)
        try containter.encode(isAbout, forKey: .isAbout)
        //try containter.encode(isIncludedIn, forKey: .isIncludedIn)
        //try containter.encode(isTaggedWith, forKey: .isTaggedWith)
        //try containter.encode(spelledIn, forKey: .spelledIn)
    }
    
    //Others
    override public func didChangeValue(forKey key: String) {
        if key == "quoteString" {
            
            //TODO: Count number of words & characters
            let a=1
            //print("Changed")
            //self.totalLetters = Int16(self.quoteString?.count)
            //self.totalWords = Int16(self.quoteString?.count)
        }
    }
}

// MARK: - Generated accessors for isTaggedWith
extension Quote {
    
    @objc(addIsTaggedWithObject:)
    @NSManaged public func addToIsTaggedWith(_ value: Tag)
    
    @objc(removeIsTaggedWithObject:)
    @NSManaged public func removeFromIsTaggedWith(_ value: Tag)
    
    @objc(addIsTaggedWith:)
    @NSManaged public func addToIsTaggedWith(_ values: NSSet)
    
    @objc(removeIsTaggedWith:)
    @NSManaged public func removeFromIsTaggedWith(_ values: NSSet)
    
}
