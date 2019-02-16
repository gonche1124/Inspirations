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
        setPrimitiveValue(false, forKey: "isFavorite")
        
    }
    
    override public func willSave() {
        if self.updatedAt.timeIntervalSinceNow>10.0 {
            setPrimitiveValue(NSDate(), forKey: "updatedAt")
        }
    }
    
    //MARK: -
    //Convinience Init form dictionary.
//    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
//        //Safeguards.
//        guard let entity = NSEntityDescription.entity(forEntityName: "Quote", in: moc),
//                let quoteS = dictionary["quoteString"] as? String, quoteS != "",
//                let authorDict=dictionary["fromAuthor"] as? [String: Any],
//                let themeDict=dictionary["isAbout"] as? [String: Any] else {
//            fatalError("Failed to create Entity Quote")}
//
//        //Create Item.
//        self.init(entity: entity, insertInto: moc)
//        self.quoteString=quoteS
//        self.from=Author.foc(named: authorDict["name"] as! String, in: moc)
//        //self.from=Author.firstOrCreate(inContext: moc, withAttributes: authorDict, andKeys: ["name"])
//        self.isAbout=Theme.foc(named: themeDict["themeName"] as! String, in: moc)
//        //self.isAbout=Theme.firstOrCreate(inContext: moc, withAttributes: themeDict, andKeys: ["themeName"])
//        if let langDefinition = NSLinguisticTagger.dominantLanguage(for: quoteS){
//            self.spelledIn=Language.foc(named: langDefinition, in: moc)
//        }
//    }
    
    /// Add infromation form the dictionary if they match the keys.
    /// - parameter from: Dictionary with values to map.
    func addAttributes(from dictionary:Dictionary<String,Any>){
        //Check if Favorite Tag exists.
        if let isFavorite = dictionary["isFavorite"] as? Bool{
            self.isFavorite=isFavorite //TODO: Handle different cases of BOOL/NSNUMBER/STRING
        }
        
        //Check if there are any Tags.
        if let tags = dictionary["isTaggedWith"] as? [[String:Any]]{
            tags.forEach({
                
                let thisTag = Tag.foc(named: $0["name"] as! String, in: self.managedObjectContext!) as? Tag
                self.addToIsTaggedWith(thisTag!)
                //self.addToIsTaggedWith(Tag.foc(named: $0["name"] as! String, in: self.managedObjectContext!))
            })
        }
        
        //Check if there are any Lists.
        if let lists = dictionary["isIncludedIn"] as? [[String:Any]]{
            lists.forEach({
                 let thisList = QuoteList.foc(named: $0["name"] as! String, in: self.managedObjectContext!) as? QuoteList
                self.addToIsIncludedIn(thisList!)
               // self.addToIsIncludedIn(QuoteList.foc(named: $0["name"] as! String, in: self.managedObjectContext!))
            })
        }
    }
    
    
    /// Easy way to create a Quote with no Author or Theme.
    public required convenience init(named:String, in context:NSManagedObjectContext) {
        self.init(context: context)
        self.quoteString=named
        if let langDefinition = NSLinguisticTagger.dominantLanguage(for: named){
            self.spelledIn=Language.foc(named: langDefinition, in: context) as! Language
        }
    }
    
    ///Create text verison for sharing services
    func textForSharing()->String{
        return self.quoteString!+"\n   ~"+self.from!.name!
    }
    
    //Creates version to test model.
    func textForML()->Dictionary<String, String>{
        return ["text": self.quoteString!, "topic":self.isAbout!.themeName!]
    }
    
}

extension Quote:CoreDataUtilities{
    public static func createWithName(name: String, in context: NSManagedObjectContext) -> Quote {
        return Quote(named: name, in: context)
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
