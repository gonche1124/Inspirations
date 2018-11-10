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
    
}
