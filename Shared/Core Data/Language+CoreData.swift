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
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Language> {
        return NSFetchRequest<Language>(entityName: "Language")
    }
    
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
    public convenience init?(named:String, inMOC:NSManagedObjectContext){
        guard let entity = NSEntityDescription.entity(forEntityName: "Language", in: inMOC),
            named != "" else {
                fatalError("Failed to create Tag")}
        
        self.init(entity: entity, insertInto: inMOC)
        self.name=named
        self.belongsToLibraryItem=inMOC.get(LibraryItem: .rootLanguage)
        self.sortingOrder=self.name
        
    }
    
    //Convinience Init.
    public convenience init(from dictionary:[String: Any], in moc:NSManagedObjectContext) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Language", in: moc) else {
            fatalError("Failed to decode Language")}
        
//        guard let path = Bundle.main.path(forResource: "BCP47", ofType: "plist") else{
//            fatalError("No dictionary for lookup codes")
//        }
//        let codeDictionary = NSDictionary(contentsOfFile: path)
        let langCode=dictionary["name"] as? String
        
        self.init(entity: entity, insertInto: moc)
        self.libraryType = .language
        self.name=langCode ?? "und"
        self.localizedName=langCode
        self.isRootItem=false
        self.belongsToLibraryItem=moc.get(LibraryItem: .rootLanguage)
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
