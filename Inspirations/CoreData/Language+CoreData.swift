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
    
    //Computed properties
    override var totalQuotes:Int?{
        print("\(self.name): \(hasQuotes?.count)")
        return hasQuotes?.count
    }
    
    //Convinience init
    public convenience init?(inMOC:NSManagedObjectContext, andName:String){
        guard let entity = NSEntityDescription.entity(forEntityName: "Language", in: inMOC),
            andName != "" else {
                fatalError("Failed to create Tag")}
        
        self.init(entity: entity, insertInto: inMOC)
        self.libraryType = LibraryType.language.rawValue
        self.name=andName
        self.isShown=true
        self.isRootItem=false
        self.belongsToLibraryItem = LibraryItem.getRootItem(withName: "Languages", inContext: inMOC)
        
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
        self.libraryType = LibraryType.language.rawValue
        self.name=langCode
        self.localizedName=langCode
        self.isShown=true
        self.isRootItem=false
        self.belongsToLibraryItem = LibraryItem.getRootItem(withName: "Languages", inContext: moc)
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
