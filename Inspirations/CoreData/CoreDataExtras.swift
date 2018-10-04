//
//  CoreDataExtras.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

//Custom keys for user dictionary
extension CodingUserInfoKey{
    static let managedContext = CodingUserInfoKey(rawValue: "managedContext")
    static let customCodingKeys = CodingUserInfoKey(rawValue: "customCodingKeys")
    static let progressText = CodingUserInfoKey(rawValue: "progressText")
}

extension LibraryItem{
    //gets root item with given name or creates one if does not exists.
    class func getRootItem(withName itemName:String, inContext:NSManagedObjectContext)->LibraryItem{
        
        let pred = NSPredicate(format: "name == %@ AND isRootItem == YES", itemName)
        if let fetchedItem = LibraryItem.firstWith(predicate: pred, inContext: inContext) as? LibraryItem {
            return fetchedItem
        }
        
        //Creat Library Item because it did not existed.
        let newItem = NSEntityDescription.insertNewObject(forEntityName: self.entity().name!, into: inContext) as! LibraryItem
        //let newItem = LibraryItem(context: inContext)
        newItem.isRootItem=true
        newItem.isShown=true
        newItem.name=itemName
        newItem.libraryType=LibraryType.rootItem.rawValue
        return newItem
    }
}

extension NSManagedObject {
    
    //Get first item with predicate
    class func firstWith(predicate:NSPredicate, inContext:NSManagedObjectContext)->NSManagedObject?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.className())
        request.predicate=predicate
        request.fetchLimit=1
        
        guard let results = try! inContext.fetch(request).first as? NSManagedObject else {return nil}
        return results
    }
    
    //Return an array with all the elements for the specefied type
//    class func arrayWithObjects()->Array<NSManagedObject>{
//        return
//    }
}

extension NSFetchRequestResult where Self: NSManagedObject {
    
    //fetches all the records.
    static public func allInContext(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Self] {
        let fetchRequest = fetchRequestForEntity(inContext: context)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        return try context.fetch(fetchRequest)
    }
    
    //USed in the baove method.
    static public func fetchRequestForEntity(inContext context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<NSManagedObject>()
        fetchRequest.entity = entity()
        return fetchRequest as! NSFetchRequest<Self>
    }
}




//TODO: Check if this is useful
/*
 extension KeyedDecodingContainer {
 
 func decodeIfPresent(_ type: Float.Type, forKey key: K, transformFrom: String.Type) throws -> Float? {
 guard let value = try decodeIfPresent(transformFrom, forKey: key) else {
 return nil
 }
 return Float(value)
 }
 
 func decode(_ type: Float.Type, forKey key: K, transformFrom: String.Type) throws -> Float? {
 return Float(try decode(transformFrom, forKey: key))
 }
 }
 */
