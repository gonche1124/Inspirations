//
//  Language+CoreData.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

@objc(Language)
public class Language: LibraryItem {
    
    @NSManaged public var localizedName: String?
    @NSManaged public var hasQuotes: NSSet?
    
    ///Computed properties used in the left controller.
    override var totalQuotes:Int?{
        return hasQuotes?.count
    }
    
    //MARK: - Overrides
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(LibraryType.language.rawValue, forKey: "libraryTypeValue")
        setPrimitiveValue(false, forKey: "isRootItem")
    }
    
    //MARK: - Convinience Init.
    //Convinience init
    
    /// Initializer based on the name.
    public convenience required init(named:String, in context:NSManagedObjectContext) {
        if named.trimWhites().isEmpty {
            fatalError("Failed to create, name is empty.")
        }
        print("INIT CALLED FROM Langauge")
        self.init(context: context)
        self.name=named
        self.belongsToLibraryItem=context.get(standardItem: .rootLanguage)
        self.sortingOrder=self.name
    }
    
}

// MARK: - Generated accessors for hasQuotes
extension Language {
    
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
extension Language:ManagesQuotes{
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
