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
        switch itemName {
        case "Library":
            newItem.sortingOrder="0"
        case "Tags":
            newItem.sortingOrder="2"
        case "Lists":
            newItem.sortingOrder="3"
        case "Languages":
            newItem.sortingOrder="4"
        default:
            newItem.sortingOrder="5"
        }
        
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
    
    //Retursn uriRepresentation as a string.
    func getID()->String{
        return self.objectID.uriRepresentation().absoluteString
    }
    
    //First or create
    class func firstOrCreate(inContext:NSManagedObjectContext, withAttributes:[String:Any])->NSManagedObject{
        
        //Create Predciate
        //TODO: Create compound predicate (Check it works)
        let predicateArray=withAttributes.map({NSPredicate(format:"%K == %@", $0,$1 as! CVarArg)})
        let finalPredicate=NSCompoundPredicate(orPredicateWithSubpredicates: predicateArray)
        
        //Fetch or create
        if let existingNSManagedObject=firstWith(predicate: finalPredicate, inContext: inContext){
            return existingNSManagedObject
        }
        
        //Create it
        //TODO: Should there be custom initialization????
        let newObject=NSEntityDescription.insertNewObject(forEntityName: self.className(), into: inContext)
        withAttributes.keys.forEach({newObject.setValue(withAttributes[$0], forKey: $0)})
        return newObject
        
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
    
    //USed in the above method.
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
