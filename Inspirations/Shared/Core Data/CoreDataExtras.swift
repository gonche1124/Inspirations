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
    ///Gets root item with given name or creates one if does not exists.
    /// - parameter itemName: name property of the root item.
    /// - parameter inContext: NSManagedContext of where the entity is to be looked for or created.
    class func getRootItem(withName itemName:String, inContext:NSManagedObjectContext)->LibraryItem{
        
        let pred = NSPredicate(format: "name == %@ AND isRootItem == YES", itemName)
        if let fetchedItem = LibraryItem.firstWith(predicate: pred, inContext: inContext) as? LibraryItem {
            return fetchedItem
        }
        
        //Creat Library Item because it did not existed.
        let newItem = NSEntityDescription.insertNewObject(forEntityName: self.entity().name!, into: inContext) as! LibraryItem
        newItem.isRootItem=true
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
    
    /// Returns a count of all Quotes
    var arrayOfQuotes:[Quote]?{
        return try? Quote.allInContext(self.managedObjectContext!)
    }
    
    /// Returns all favorites.
    var arrayOfFavorites:[Quote]?{
        return try? Quote.allInContext(self.managedObjectContext!, predicate: NSPredicate(format: NSPredicate.pIsFavorite))
    }
    
    //Get first item with predicate
    class func firstWith<T: NSManagedObject>(predicate:NSPredicate, inContext:NSManagedObjectContext)->T?{
        let request = NSFetchRequest<T>(entityName: self.className())
        request.predicate=predicate
        request.fetchLimit=1
        if let item=try? inContext.fetch(request).first{
            return item
        }
        return nil
    }
    
    //returns first object with a given attribute. Convinience for not constructing NSPredciate.
    class func firstWith<T: NSManagedObject>(attribute:String, value:Any, inContext:NSManagedObjectContext)->T?{
        let predicate=NSPredicate(format:"%K == %@", attribute,value as! CVarArg)
        return self.firstWith(predicate: predicate, inContext: inContext)
    }
    
    ///Returns uriRepresentation as a string.
    func getID()->String{
        return self.objectID.uriRepresentation().absoluteString
    }
    
    /// Returns the first match of the entity with the given attributes or creates and returns one if none available
    /// - parameter moc: NSManagedObjectContext.
    /// - parameter withAttributes: Dictionary with strings and values of entity.
    /// - parameter andkeys: keys used to sort or match the entity.
    class func firstOrCreate<T: NSManagedObject>(inContext moc:NSManagedObjectContext, withAttributes:[String:Any], andKeys keys:[String]?=nil)->T{
        
        //Create Predciate
        var newDict=withAttributes
        if let keysArray=keys{
            newDict = withAttributes.filter({keysArray.contains($0.key)})
        }
        let predicateArray=newDict.map({NSPredicate(format:"%K == %@", $0.key, $0.value as! CVarArg)})
        let finalPred=NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        
        //Fetch or create
        if let existingNSManagedObject=firstWith(predicate: finalPred, inContext:moc) as? T{
            return existingNSManagedObject
        }
        
        //Create it
        let newObj=try! createEntity(withDictionary: withAttributes, in: moc)
        return newObj as! T
    }
    
    //Evaluates type of core data entity and performs init.
    //TODO: Potential to be recycled.
   class func createEntity<T:NSManagedObject>(withDictionary:[String:Any], in moc:NSManagedObjectContext) throws ->T?{
    switch String(describing: self) {
        case Entities.quote.rawValue:
            return try Quote.init(from: withDictionary, in: moc) as? T
        case Entities.author.rawValue:
            return try Author.init(from: withDictionary, in: moc) as? T
        case Entities.theme.rawValue:
            return try Theme.init(from: withDictionary, in: moc) as? T
        case Entities.tag.rawValue:
            return try Tag.init(from: withDictionary, in: moc) as? T
        case Entities.language.rawValue:
            return try Language.init(from: withDictionary, in: moc) as? T
        case Entities.collection.rawValue:
            return try QuoteList.init(from: withDictionary, in: moc) as? T
        //case Entities.library.rawValue:
        //    return LibraryItem.init(inMOC: <#T##NSManagedObjectContext#>, andName: <#T##String#>, isRoot: <#T##Bool#>)
        default:
            return nil
        }
    }
}

//MARK: - 
extension NSFetchRequestResult where Self: NSManagedObject {
    
    //fetches all the records.
    static public func allInContext(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Self] {
        let fetchRequest = fetchRequestForEntity(inContext: context)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        return try context.fetch(fetchRequest)
    }
    
    //Used in the above method.
    static public func fetchRequestForEntity(inContext context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<NSManagedObject>()
        fetchRequest.entity = entity()
        return fetchRequest as! NSFetchRequest<Self>
    }
    
    //Create a simple request for fecthing
    static public func singleRequest()->NSFetchRequest<Self>{
        let request = NSFetchRequest<Self>(entityName: self.className())
        request.fetchLimit=1
        return request
    }
}

//MARK: -
extension NSManagedObjectContext{
    
    /// Fetches objects from core data IDS represented as array of strings.
    /// - parameter asStrings: Array of string that represent core data objetc IDs.
    func getObjectsWithIDS(asStrings: [String])->[NSManagedObject]?{
        guard let urlArray = asStrings.map({URL.init(string: $0)}) as? [URL],
            let objectIDArray = urlArray.map({self.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0)}) as? [NSManagedObjectID] else {
            return nil
        }
        return objectIDArray.map({self.object(with: $0 )})
    }
    
    /// Fetches the core data object with the given string ID
    /// - parameter objectWithStringID: representation of the core data objects as a string.
    func get(objectWithStringID:String)->NSManagedObject?{
        guard let object=self.getObjectsWithIDS(asStrings: [objectWithStringID])?.first else {return nil}
        return object
    }
    
    /// Gets the number of entities returned for the given predicate in the given entity.
    /// - parameter ofEntity: Entity to perform the fetch on.
    /// - parameter predicate: NSPredicate used to filter the results.
    /// - Note: Used to determine how many quotes are associate to smart lists.
    /// - TODO: Change to return count.
    func count(ofEntity:String, with predicate:NSPredicate)->Int?{
        let fetchR=NSFetchRequest<NSFetchRequestResult>.init(entityName: ofEntity)
        fetchR.predicate=predicate
        return try? self.count(for: fetchR)
    }
    
    /// Returns the main library object.
    func getItem(ofType: LibraryType)->LibraryItem?{
        let request = LibraryItem.singleRequest()
        request.predicate = NSPredicate.getItem(ofType)
        let item=try? self.fetch(request).first
        return item ?? nil
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
