//
//  ImportExport.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa
//import Sync



class importExport: NSObject {
    
    fileprivate lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext

    
    // MARK: - Export
    //Return an Array with all the Quotes
    func retrieveArrayOfRecords()-> [Dictionary<String,Any>] {

        var listQuotes = [Dictionary<String,Any>]()
        do{
            let fetchRequestAsDictionary=NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
            fetchRequestAsDictionary.returnsObjectsAsFaults=false
            fetchRequestAsDictionary.relationshipKeyPathsForPrefetching=["fromAuthor.name"]
            let records = try moc.fetch(fetchRequestAsDictionary)
            
            for case let item as Quote in records {
                listQuotes.append(item.convertToDictionary())
            }
           return listQuotes
            
        }catch{
            print("Could not print the records")
            fatalError(error as! String)
        }
    }
    
    //Get all the quotes as String
    func exportAllTheQuotes(){
        
        //Get teh data as string
        let arrayToConvert = self.retrieveArrayOfRecords()
        let stringJSON = self.toJSONString(objectToConvert: arrayToConvert as AnyObject)

        //Prompt user for location to save
        let dialog = NSSavePanel()
        dialog.title = "Export quotes"
        dialog.showsResizeIndicator=true
        dialog.message="Choose where you want to save your data"
        dialog.canCreateDirectories=true
        dialog.directoryURL=try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK){
            try! stringJSON.write(to: dialog.url!, atomically: false, encoding: .utf8)
        }
    }
    
    //Converts Object to JSON
    func toJSONString(objectToConvert: AnyObject) -> String {
        if let dat = try? JSONSerialization.data(withJSONObject: objectToConvert, options: JSONSerialization.WritingOptions.prettyPrinted),
            let str = String(data: dat, encoding: String.Encoding.utf8) {
            return str
        }
        return "[]"
    }
    
    // MARK: - Import
    
    //MARK: - Test
    
    //Test for simplification
    //Looks for object, if does not find one it creates it.
    func findOrCreateObject(entityName: String, attributesDict: Dictionary<String,Any>)->NSManagedObject{
        
        //Get uniqueness key
        let currEntDes = moc.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]
        //The case where there is no unique key will not happen, this can be erased if easier way to flaten and access first object is found.
        guard let uniqKey = currEntDes?.uniquenessConstraints[0].first as? String else {
            return NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc)
        }
        
        //Create fetchRequest
        let fRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fRequest.predicate = NSPredicate(format: "%K == %@", uniqKey, attributesDict[uniqKey] as! String)
        
        //Fetch
        let allObjects = try! moc.fetch(fRequest) as! [NSManagedObject]
        return (allObjects.count>0) ? allObjects[0]:NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc)

    }
    
    
    //Suport the JSON parser.
    func nullToNil(value : Any?) -> Any? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    func createNSManagedObject(fromDict: Dictionary<String,Any>, includingRelations: Bool=false)->NSManagedObject{
        //Fetch or create new entity.
        let entityName = fromDict["className"] as! String
        let newEntity = findOrCreateObject(entityName: entityName, attributesDict: fromDict)
        
        //Populate attributes is working after nullToNil
        _=newEntity.entity.attributeKeys.map({newEntity.setValue(nullToNil(value:fromDict[$0]), forKey: $0)})
        
        //Check if it needs to fill relationships.
         if !includingRelations {return newEntity}
        
        //Fill 1 to 1 relationships
        let oneToOne = newEntity.entity.toOneRelationshipKeys
        _=oneToOne.map({newEntity.setValue(createNSManagedObject(fromDict: fromDict[$0] as! Dictionary<String, Any>), forKey: $0)})
        
        //Fill To Many relationships
        for currKey in newEntity.entity.toManyRelationshipKeys {
            let allItems = newEntity.mutableSetValue(forKey: currKey)
            let newItems = (fromDict[currKey] as! NSArray).map({createNSManagedObject(fromDict: $0 as! Dictionary<String, Any>)})
            allItems.addObjects(from: newItems)
            newEntity.setValue(allItems, forKey: currKey)
        }
        
        try! moc.save()
        return newEntity
    }
    

    //FIn test
    
    
    //Looks for an object, creates one if there is not one there.
//    func findOrCreateEntity(key: String, value: Any, entityString: String, moc2: NSManagedObjectContext)->NSManagedObject{
//
//        //Testing to move up with only 1 key of uniqueness
//        guard let uniqKey = moc.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityString]?.uniquenessConstraints.first?.first as? String else {
//            return NSEntityDescription.insertNewObject(forEntityName: entityString, into: moc2)
//        }
////        guard let uniqKey = Quote.entity().uniquenessConstraints.first?.first as? String else {
////            return NSEntityDescription.insertNewObject(forEntityName: entityString, into: moc2)
////        }
//        let fRequ = NSFetchRequest<NSFetchRequestResult>(entityName: entityString)
//        let thisP = NSPredicate(format: "%K == %@", uniqKey, value as! String)
//        fRequ.predicate = thisP
//
//
//
//        //Configire search
//        let fetchReq=NSFetchRequest<NSFetchRequestResult>(entityName: entityString)
//        let fetchPredicate = NSPredicate(format: "%K == %@", key, value as! String)
//        fetchReq.predicate=fetchPredicate
//
//        //Execute fetch
//        let managedObject = try! moc2.fetch(fetchReq) as! [NSManagedObject]
//        if managedObject.count > 0 {
//            return managedObject.first!
//        }
//        else {
//            return NSEntityDescription.insertNewObject(forEntityName: entityString, into: moc2)
//        }
//    }
    
    //Creates a managed Object for the specified class, with the attributes as
    //dictionary and in the moc passed as parameter
    
//    func createManagedObject(attributes:Dictionary<String, Any>, Entity: String, inManagedObjectContext: NSManagedObjectContext)->NSManagedObject{
//
//        var newObject: NSManagedObject
//        switch Entity {
//            case "fromAuthor":
//                newObject=findOrCreateEntity(key: "name", value: ((attributes["name"]!) as AnyObject).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), entityString: "Author",  moc2:moc)
//            case "isAbout":
//                newObject=findOrCreateEntity(key: "topic", value: attributes["topic"]!, entityString: "Theme", moc2:moc)
//            case "tags":
//                newObject=findOrCreateEntity(key: "tag", value: attributes["tag"]!, entityString: "Tag", moc2:moc)
//            default:
//                newObject=findOrCreateEntity(key: "quote", value: attributes["quote"]!, entityString: "Quote", moc2:moc)
//        }
//
//        newObject.populateFromDictionary(attributesDictionary: attributes)
//        //try!moc.save() //Added this line after error on run due to changing removed object
//        return newObject
//    }
    
    //Import data from a JSON file
    func importFromJSONV2(pathToFile: URL ){
        
        //Read into Array
        let jsonData = NSData(contentsOf: pathToFile)
        let jsonArray = try! JSONSerialization.jsonObject(with: (jsonData)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, Any>]
        
        //COuld convert to higher order??
        for jsonItem in jsonArray {
            let currItem = jsonItem as! Dictionary<String, Any>
            
            _ = createNSManagedObject(fromDict: currItem, includingRelations: true)
 
//            _ = createManagedObject(attributes: currItem,
//                                                   Entity: "Quote",
//                                                   inManagedObjectContext: moc) as! Quote
//
            do{
                try moc.save()
            }
            catch{
                print(error)
            }
            
        }
    }
    
}

 //MARK: -  Extensions
//Extension to NSMAnagedObject to enable conversion into a NSDictionary
extension NSManagedObject{
    
    func addObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.add(value)
    }
    
    func removeObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.remove(value)
    }
    
    
    //Only does one level with recursivity. TO DO: Figure out how to remove that constraint.
    //TODO: Include boolean to include relationships.
    func convertToDictionary() -> Dictionary<String, Any>{
        
        //Get Attributes of object into a dictionary
        var dict = self.dictWithAttributes()
        
        //Get relationships 1->1
        _ = self.entity.toOneRelationshipKeys.map({dict[$0]=(self.value(forKey: $0) as? NSManagedObject)?.dictWithAttributes()})

        //Get relationships 1->Many
        let toMany = self.entity.toManyRelationshipKeys
        for thisKey in toMany {
            dict[thisKey] = (self.value(forKey: thisKey) as? NSSet)?.allObjects.map({($0 as? NSManagedObject)?.dictWithAttributes()})
        }
       return dict
    }
    
    //Returns a dictionary with keys as attributes and values as values.
    func dictWithAttributes()->Dictionary<String,Any>{
        var entityDict = self.dictionaryWithValues(forKeys: self.entity.attributeKeys)
        entityDict["className"] = self.entity.name
        return entityDict
    }
    
//    //Populates the attributes from a dictionary
//    func populateFromDictionary(attributesDictionary: Dictionary<String, Any>){
//        let moc2 = self.managedObjectContext
//
//        for case let key:String in attributesDictionary.keys {
//            let value = attributesDictionary[key] as! NSObject
//            //Check on-to-one relationship
//            if value is Dictionary<String, Any> {
//                let IE = importExport()
//                let relationObject = IE.createManagedObject(attributes: value as! Dictionary<String, Any>,
//                                                                Entity: key,
//                                                inManagedObjectContext: moc2!) as NSManagedObject
//
//                self.setValue(relationObject, forKeyPath: key)
//            }
//
//            //Check one-to-many relationship
//            else if value is NSArray {
//                let objectSet = NSSet()
//                let IE = importExport()
//                for arrayItem in value as! NSArray {
//                    let setItem = IE.createManagedObject(attributes: arrayItem as! Dictionary<String, Any>,
//                                                         Entity: key, inManagedObjectContext: moc2!) as NSManagedObject
//                    objectSet.adding(setItem)
//                }
//                self.setValue(objectSet, forKeyPath: key)
//            }
//
//            //Check if it is an attribute
//            else{
//                if !(value is NSNull) {
//                    self.setValue(value, forKey: key)
//                }
//            }
//        }
//    }

}



