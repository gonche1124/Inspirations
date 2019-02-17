//
//  CoreDataExtras.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData


//Testing.
public protocol CoreDataUtilities {
    init(named: String, in context:NSManagedObjectContext)
}

extension NSManagedObject {

    /// Used to set enums in variables firing up KVO notifications.
    /// - parameter value: Value to assign.
    /// - parameter key: String refering a proeprty form the NSManagedObject.
    func setRawValue<ValueType: RawRepresentable>(value: ValueType, forKey key: String){
        self.willChangeValue(forKey: key)
        self.setPrimitiveValue(value.rawValue, forKey: key)
        self.didChangeValue(forKey: key)
    }
    
    /// Used to get enums in variables firing up KVO notifications.
    /// - parameter key: String refering a property from the NSManagedObject.
    func rawValueForKey<ValueType: RawRepresentable>(key: String) -> ValueType?{
        self.willAccessValue(forKey: key)
        let result = self.primitiveValue(forKey: key) as! ValueType.RawValue
        self.didAccessValue(forKey: key)
        return ValueType(rawValue:result)
    }
    
    ///Returns uriRepresentation as a string.
    func getID()->String{
        return self.objectID.uriRepresentation().absoluteString
    }
}



//MARK: - 
extension NSFetchRequestResult where Self: NSManagedObject, Self:CoreDataUtilities {
    
    /// Gets all objects of the calling entity.
    /// - parameter in: NSManagedObjectContext used to fecth the entities.
    /// - parameter with: NSPredicate used to filter the results.
    /// - TODO: Include NSSort descriptors.
    static func objects(in context:NSManagedObjectContext, with predicate:NSPredicate?=nil) throws ->[Self]{
        let request = NSFetchRequest<Self>(entityName: Self.className())
        request.predicate = predicate
        return try context.fetch(request)
    }
    
    /// Counts the objects of the calling entity.
    /// - parameter in: NSManagedObjectContext used to fecth the entities.
    /// - parameter with: NSPredicate used to filter the results.
    static func count(in context:NSManagedObjectContext, with predicate:NSPredicate?=nil) throws ->Int{
        let request = NSFetchRequest<Self>(entityName: Self.className())
        request.predicate=predicate
        return try context.count(for: request)
    }
    
    /// Gets the first item with the given name or creates one if no results.
    /// - parameter named: String to use as name.
    static func foc(named:String, in context:NSManagedObjectContext)->Self{
        //Get item
        let request = NSFetchRequest<Self>(entityName: self.className())
        request.predicate = Self.entity().predicate(with: named)
        request.fetchLimit=1
        if let result = try? context.fetch(request), let item = result.first {
            return item
        }
        //Create because it does not exists.
        return Self(named: named, in: context)
    }
}

//MARK: -
extension NSManagedObjectContext{
    
    /// Fetches objects from core data IDS represented as array of strings.
    /// - parameter asStrings: Array of string that represent core data objetc IDs.
    func getObjectsWithIDS(asStrings: [String])->[NSManagedObject]?{
//        guard let urlArray = asStrings.map({URL.init(string: $0)}) as? [URL],
//            let objectIDArray = urlArray.map({self.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0)}) as? [NSManagedObjectID] else {
//            return nil
//        }
        //return objectIDArray.map({self.object(with: $0 )})
        return asStrings.compactMap{URL.init(string: $0)}.compactMap{self.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0)}.compactMap{self.object(with: $0)}
    }
    
    /// Returns the standard library object, creating it if it does not exist.
    /// - parameter standardItem: they type of item you want ot retrieve.
    /// - note: It has to be one of the standard items or it will fail.
    /// - note: the item has to exist, otherwise it will return nil
    func get(standardItem ofType: LibraryType)->LibraryItem{
        if !LibraryType.standardItems.contains(ofType){
            fatalError("Not a standard item: \(ofType)")
        }
        let request = NSFetchRequest<LibraryItem>(entityName:Entities.library.rawValue)//LibraryItem.singleRequest()
        request.predicate = NSPredicate.forItem(ofType: ofType)
        if let array = try? self.fetch(request), let item = array.first {
             return item
        } else {
            //Item does not exists, so it will create it or throw error.
            let newItem = LibraryItem.init(standardType: ofType, inMOC: self)
            return newItem
        }
    }
}
//MARK: -
/// Protocol used to simplify read and write of quotes that are managed by another entity.
protocol ManagesQuotes {
    ///Return the list of quotes associated with the entity.
    func containsQuotes()->[Quote]
    /// Adds a quote to the relationship of the current object.
    func addQuote(quote:Quote)
    /// Adds an array of Quotes to the relationship of the current object.
    func addQuotes(quotes:[Quote])
    /// Removes the given quotes from the relationship of the given entity.
    func removeQuote(quote:Quote)
    /// Removes the given quotes from the relationship of the given entity.
    func removeQuotes(quote:[Quote])
}
//test
//extension KeyedDecodingContainer{
//    private enum authorEnconding:String, CodingKey{
//        case name = "name"
//    }
//
//    //NOTE: Implement. Important!
//    //https://stackoverflow.com/questions/44603248/how-to-decode-a-property-with-type-of-json-dictionary-in-swift-4-decodable-proto
//    func decodeAuthor(forKey key:K, inMOC moc:NSManagedObjectContext) throws ->Author?{
//      //  let authorDict=try self.decode([String: Any].self, forKey: key)
////        if let exists = Author.firtsWith(attribute: "name", value: authorDict.name, inContext: moc) as? Author{
////            return exists
////        }
//
//        return try decode(Author.self, forKey: key)
//    }
//
//    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
//        let container = try self.nestedContainer(keyedBy: gonche.self, forKey: key)
//        return try container.decode(type)
//    }
//
//    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
//        var dictionary = Dictionary<String, Any>()
//
//        for key in allKeys {
//            if let boolValue = try? decode(Bool.self, forKey: key) {
//                dictionary[key.stringValue] = boolValue
//            } else if let stringValue = try? decode(String.self, forKey: key) {
//                dictionary[key.stringValue] = stringValue
//            } else if let intValue = try? decode(Int.self, forKey: key) {
//                dictionary[key.stringValue] = intValue
//            } else if let doubleValue = try? decode(Double.self, forKey: key) {
//                dictionary[key.stringValue] = doubleValue
////            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
////                dictionary[key.stringValue] = nestedDictionary
////            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
////                dictionary[key.stringValue] = nestedArray
//            }
//        }
//        return dictionary
//    }
//}
//
//extension UnkeyedDecodingContainer{
//
//    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
//
//        let nestedContainer = try self.nestedContainer(keyedBy: gonche.self)
//        return try nestedContainer.decode(type)
//    }
//}


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
