//
//  Tag+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: LibraryItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    //Properties
    @NSManaged public var hasQuotes: NSSet?
    
    ///Computed properties used in the left controller.
    override var totalQuotes:Int?{
        return hasQuotes?.count
    }
    
    //MARK: - Overrides
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(LibraryType.tag.rawValue, forKey: "libraryTypeValue")
        setPrimitiveValue(false, forKey: "isRootItem")
    }
    
    //MARK: - Convinience Init
    //Convinience init.
    public convenience init?(named:String, inMOC:NSManagedObjectContext){
        guard let entity = NSEntityDescription.entity(forEntityName: "Tag", in: inMOC),
        named != "" else {
            fatalError("Failed to create Tag")}
        
        self.init(entity: entity, insertInto: inMOC)
        self.name=named
        self.sortingOrder=self.name
        self.belongsToLibraryItem=inMOC.get(LibraryItem: .rootTag)
    }
    
    //Convinience Init.
    public convenience init?(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let name = dictionary["name"] as? String else {
            fatalError("Failed to decode Tag")}
        self.init(named: name, inMOC: moc)
    }
    
}

// MARK: - Generated accessors for hasQuotes
extension Tag {
    
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
extension Tag {
    override public func validateForUpdate() throws {
        if self.hasQuotes?.count==0 {
            self.managedObjectContext?.delete(self)
        }
    }
}

//MARK: - Protocols:
extension Tag:ManagesQuotes{
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
