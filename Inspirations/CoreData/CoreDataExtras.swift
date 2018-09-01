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
}

extension LibraryItem{
    //gets root item with given name or creates one if does not exists.
    class func getRootItem(withName itemName:String, inContext:NSManagedObjectContext)->LibraryItem{
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: self.className())
        request.predicate = NSPredicate(format: "name == %@", itemName)
        request.fetchLimit=1
        
        if let results = try! inContext.fetch(request).first as? LibraryItem {return results}
        
        //Creat Library Item
        let newItem = LibraryItem(context: inContext)
        newItem.isRootItem=true
        newItem.name=itemName
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
