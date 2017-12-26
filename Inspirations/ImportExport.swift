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
    
    //Variables
    fileprivate lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate lazy var bMoc = (NSApp.delegate as! AppDelegate).privateQueueContext
    var progressInstance: Progress?

    
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
    
    //Test for simplification
    //Looks for object, if does not find one it creates it.
    func findOrCreateObject(entityName: String, attributesDict: Dictionary<String,Any>)->NSManagedObject{
        
        //Get uniqueness key
        let currEntDes = bMoc.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]
        //The case where there is no unique key will not happen, this can be erased if easier way to flaten and access first object is found.
        guard let uniqKey = currEntDes?.uniquenessConstraints[0].first as? String else {
            return NSEntityDescription.insertNewObject(forEntityName: entityName, into: bMoc)
        }
        
        //Create fetchRequest
        let fRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fRequest.predicate = NSPredicate(format: "%K == %@", uniqKey, attributesDict[uniqKey] as! String)
        
        //Fetch
        let allObjects = try! bMoc.fetch(fRequest) as! [NSManagedObject]
        return (allObjects.count>0) ? allObjects[0]:NSEntityDescription.insertNewObject(forEntityName: entityName, into: bMoc)

    }
    
    
    //Suport the JSON parser.
    /// Checks if the value is NULL or not.
    ///
    /// - Parameter value: vale to check if it is null.
    /// - Returns: Original value or nil.
    func nullToNil(value : Any?) -> Any? {
        return (value is NSNull) ? nil : value
    }
    
    func createNSManagedObject(fromDict: Dictionary<String,Any>, includingRelations: Bool=false)->NSManagedObject{
        
        //DispatchQueue.global(qos: .background).async{
            //Fetch or create new entity.
            let entityName = fromDict["className"] as! String
            let newEntity = self.findOrCreateObject(entityName: entityName, attributesDict: fromDict)
            
            //Populate attributes is working after nullToNil
            _=newEntity.entity.attributeKeys.map({newEntity.setValue(self.nullToNil(value:fromDict[$0]), forKey: $0)})
            
            //Check if it needs to fill relationships.
            //if !includingRelations {return newEntity}
            if includingRelations {
                //Fill 1 to 1 relationships
                let oneToOne = newEntity.entity.toOneRelationshipKeys
                _=oneToOne.map({newEntity.setValue(self.createNSManagedObject(fromDict: fromDict[$0] as! Dictionary<String, Any>), forKey: $0)})
                
                //Fill To Many relationships
                for currKey in newEntity.entity.toManyRelationshipKeys {
                    guard let arrayToAdd = (fromDict[currKey] as? NSArray) else {continue}
                    let newItems = arrayToAdd.map({self.createNSManagedObject(fromDict: $0 as! Dictionary<String, Any>)})
                    let allItems = newEntity.mutableSetValue(forKey: currKey)
                    allItems.addObjects(from: newItems)
                    newEntity.setValue(allItems, forKey: currKey)
                }
            }
            try! self.bMoc.save()
        //}
 
        return newEntity
      
    }
    
    //Parse JSON File
    func parseJSONFile(pathToFile: URL)->[Dictionary<String, Any>]{
        let jsonData = NSData(contentsOf: pathToFile)
        let jsonArray = try! JSONSerialization.jsonObject(with: (jsonData)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, Any>]
        
        self.progressInstance = Progress(totalUnitCount: Int64(jsonArray.count))
        return jsonArray
        
    }
    
    
    //Import data from a JSON file
    func importFromJSONV2(array: [Dictionary<String, Any>]){
        
        DispatchQueue.global(qos: .background).async {
            for (n,jsonItem) in array.enumerated() {
                //print("procesed item \(n)")
                //print ("\(jsonItem["quote"])")
                _ = self.createNSManagedObject(fromDict: jsonItem, includingRelations: true)
                self.progressInstance?.completedUnitCount = Int64(n)
                try! self.bMoc.save()
            }
        }
    }
}

 //MARK: -  Extensions
//Extension to NSMAnagedObject to enable conversion into a NSDictionary
extension NSManagedObject{
    
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
}



