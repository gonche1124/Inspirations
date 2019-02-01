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
public class Quote: NSManagedObject{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quote> {
        return NSFetchRequest<Quote>(entityName: "Quote")
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
    @NSManaged public var createdAt:NSDate
    @NSManaged public var updatedAt:NSDate
    
    
    //MARK: - Overrides
    override public func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "createdAt")
        setPrimitiveValue(NSDate(), forKey: "updatedAt")
    }
    
    override public func willSave() {
        if self.updatedAt.timeIntervalSinceNow>10.0 {
            setPrimitiveValue(NSDate(), forKey: "updatedAt")
        }
    }
    
    //MARK: -
    //Convinience Init form dictionary.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        //Safeguards.
        guard let entity = NSEntityDescription.entity(forEntityName: "Quote", in: moc),
                let quoteS = dictionary["quoteString"] as? String, quoteS != "",
                let authorDict=dictionary["fromAuthor"] as? [String: Any],
                let themeDict=dictionary["isAbout"] as? [String: Any] else {
            fatalError("Failed to create Entity Quote")}
        
        //Create Item.
        self.init(entity: entity, insertInto: moc)
        self.quoteString=quoteS
        self.from=Author.firstOrCreate(inContext: moc, withAttributes: authorDict, andKeys: ["name"])
        self.isAbout=Theme.firstOrCreate(inContext: moc, withAttributes: themeDict, andKeys: ["themeName"])
        if let lang = Language.firstOrCreate(inContext: moc, withAttributes: ["name":NSLinguisticTagger.dominantLanguage(for: quoteS)! as Any], andKeys: ["name"]) as? Language{
            lang.addToHasQuotes(self)
        }
        

        //Check if Favorite Tag exists.
        if let isFavorite = dictionary["isFavorite"] as? Bool{
            self.isFavorite=isFavorite //TODO: Handle different cases of BOOL/NSNUMBER/STRING
        }
        
        //Check if there are any Tags.
        if let tags = dictionary["isTaggedWith"] as? [[String:Any]]{
            tags.forEach({
                self.addToIsTaggedWith(Tag.firstOrCreate(inContext: moc, withAttributes: $0, andKeys: ["name"]))
            })
        }
        
        //Check if there are any Lists.
        if let lists = dictionary["isIncludedIn"] as? [[String:Any]]{
            lists.forEach({
                self.addToIsTaggedWith(QuoteList.firstOrCreate(inContext: moc, withAttributes: $0, andKeys: ["name"]))
            })
        }
    }
    
    //Decodable
    /*
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
       
        //let author = try container.decode(Dictionary<String:Any>, forKey: .from)
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
    */

    
    //Updates when the user changes the length of the quote.
//    override public func didChangeValue(forKey key: String) {
//        if key == "quoteString" {
//            let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
//            if let components = self.quoteString?.components(separatedBy: chararacterSet).filter({!$0.isEmpty}){
//                self.totalWords = Int16(components.count)
//                self.totalLetters = Int16(components.map({$0.count}).reduce(0,+))
//            }
//        }
//    }
    
    ///Create text verison for sharing services
    func textForSharing()->String{
        return self.quoteString!+"\n   ~"+self.from!.name!
    }
    
    //Creates version to test model.
    func textForML()->Dictionary<String, String>{
        return ["text": self.quoteString!, "topic":self.isAbout!.themeName!]
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

// MARK: - Generated accessors for isIncludedIn
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
