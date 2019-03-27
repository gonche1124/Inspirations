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
    
    //Properties
    @NSManaged public var isFavorite: Bool
    @NSManaged public var quoteString: String?
    @NSManaged public var totalLetters: Int16
    @NSManaged public var totalWords: Int16
    @NSManaged public var from: Author?
    @NSManaged public var isAbout: Theme?
    @NSManaged public var isIncludedIn: Set<QuoteList>?
    @NSManaged public var isTaggedWith: Set<Tag>?
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
                self.addToIsTaggedWith(Tag.foc(named: $0["name"] as! String, in: self.managedObjectContext!))
            })
        }
        
        //Check if there are any Lists.
        if let lists = dictionary["isIncludedIn"] as? [[String:Any]]{
            lists.forEach({
               self.addToIsIncludedIn(QuoteList.foc(named: $0["name"] as! String, in: self.managedObjectContext!))
            })
        }
    }
    
    
    /// Easy way to create a Quote with no Author or Theme.
    public required convenience init(named:String, in context:NSManagedObjectContext) {
        self.init(context: context)
        self.quoteString=named
        if let langDefinition = NSLinguisticTagger.dominantLanguage(for: named){
            self.spelledIn=Language.foc(named: langDefinition, in: context)
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

extension Quote:CoreDataUtilities{}

//MARK: -
extension Quote:Encodable{
    
    //Coding
    enum CodingKeys: String, CodingKey {
        case quoteString, isFavorite, from, isAbout, IsTaggedWith, IsIncludedIn
    }
  
    
    //Encodes the instance into JSON.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quoteString, forKey: .quoteString)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(from, forKey: .from)
        try container.encode(isAbout, forKey: .isAbout)
        try container.encodeIfPresent(isTaggedWith, forKey: .IsTaggedWith)
        try container.encodeIfPresent(isIncludedIn, forKey: .IsIncludedIn)
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
