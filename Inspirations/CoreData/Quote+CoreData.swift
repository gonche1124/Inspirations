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
    @NSManaged public var isIncludedIn: NSSet?
    @NSManaged public var isTaggedWith: NSSet?
    @NSManaged public var spelledIn: Language?
    
    //Convinience Init.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Quote", in: moc) else {
            fatalError("Failed to decode Quote")}
        
        self.init(entity: entity, insertInto: moc)
        if let quoteS = dictionary["quote"] as? String{
            self.quoteString=quoteS
        }
        if let authorDict=dictionary["fromAuthor"] as? [String: Any]{
            self.from=Author.firstOrCreate(inContext: moc, withAttributes: authorDict, and: ["name"])
        }
        if let themeDict=dictionary["isAbout"] as? [String: Any]{
            self.isAbout=Theme.firstOrCreate(inContext: moc, withAttributes: themeDict, and: ["themeName"])
        }
        //TODO: Implement favorites and lists.
        
    }
    
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
        //TODO: try to remove uniquenes constaints and decode Author into dictionary first
        //let author = try container.decode(Dictionary<String:Any>, forKey: .from)
        let auth = try container.decodeAuthor(forKey: .from, inMOC: moc)
        let theAuthor=try container.decode(Author.self, forKey: .from)
        theAuthor.addToHasSaid(self)
        self.from=theAuthor
        let theTheme=try container.decode(Theme.self, forKey: .isAbout)
        theTheme.addToHasQuotes(self)
        self.isAbout=theTheme
        if let inLists = try container.decodeIfPresent([QuoteList].self, forKey: .isIncludedIn){
            self.addToIsIncludedIn(NSSet(array: inLists))
        }
        
        //ProgressBar
        if let textField = decoder.userInfo[CodingUserInfoKey.progressText!] as? NSTextField,
            let totItems = decoder.codingPath.first?.intValue {
            DispatchQueue.main.async {
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                textField.stringValue="Imported \(formatter.string(for: totItems)!) quotes"
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
    //Updates when the user changes the length of the quote.
    override public func didChangeValue(forKey key: String) {
        if key == "quoteString" {
            let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            if let components = self.quoteString?.components(separatedBy: chararacterSet).filter({!$0.isEmpty}){
                self.totalWords = Int16(components.count)
                self.totalLetters = Int16(components.map({$0.count}).reduce(0,+))
            }
        }
    }
    
    //Prints the description
//    override open var description: String{
//
//        return "AA\nBB"
//    }
    
   
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


// MARK: Generated accessors for isIncludedIn
extension Quote {
    
    @objc(addIsIncludedInObject:)
    @NSManaged public func addToIsIncludedIn(_ value: QuoteList)
    
    @objc(removeIsIncludedInObject:)
    @NSManaged public func removeFromIsIncludedIn(_ value: QuoteList)
    
    @objc(addIsIncludedIn:)
    @NSManaged public func addToIsIncludedIn(_ values: NSSet)
    
    @objc(removeIsIncludedIn:)
    @NSManaged public func removeFromIsIncludedIn(_ values: NSSet)
    
}
