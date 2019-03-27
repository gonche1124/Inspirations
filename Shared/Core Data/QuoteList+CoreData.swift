//
//  QuoteList+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(QuoteList)
public class QuoteList: LibraryItem {
    
    //Properties
    @NSManaged public var smartPredicate: NSPredicate?
    @NSManaged public var hasQuotes: NSSet?
    
    ///Computed properties used in the left controller.
    override var totalQuotes:Int?{
        if let predicate=smartPredicate{
            return try? Quote.count(in: self.managedObjectContext!, with: predicate)
        }
        return hasQuotes?.count
    }
    
    override var quotePredicate: NSPredicate{
        if let predicate=self.smartPredicate {
            return predicate
        }
        return NSPredicate(format: "ANY isIncludedIn.name contains [CD] %@",  self.name)
    }
    
    //MARK: - Overrides
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(LibraryType.list.rawValue, forKey: "libraryTypeValue")
        setPrimitiveValue(false, forKey: "isRootItem")
    }
    
    //MARK: - Convinience Init.
    //Convinience init
    public convenience init?(inMOC:NSManagedObjectContext, andName:String, withSmartList:NSPredicate?=nil){
        guard let entity = NSEntityDescription.entity(forEntityName: "QuoteList", in: inMOC),
            andName != "" else {
                fatalError("Failed to create Quote List")}
        self.init(entity: entity, insertInto: inMOC)
        self.name=andName
        self.sortingOrder=self.name
        self.belongsToLibraryItem=inMOC.get(standardItem: .rootList)
        if (withSmartList != nil)  {
            self.smartPredicate=withSmartList
            self.libraryType = .smartList
        }
    }
    
    //Convinience Init.
    public convenience init?(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let listName = dictionary["name"] as? String else {
            fatalError("Failed to create Quote List")}
        self.init(inMOC: moc, andName: listName)
    }

}

//MARK: -
extension QuoteList:Encodable{
    
    //Coding
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    
    //Encodes the instance into JSON.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

// MARK: - Generated accessors for hasQuotes
extension QuoteList {
    
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
extension QuoteList:ManagesQuotes{
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
