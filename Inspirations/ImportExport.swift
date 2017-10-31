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
    
    fileprivate lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext

    
    
    
    // MARK: - Export
    //Return an Array with all the Quotes
    func retrieveArrayOfRecords()-> [Dictionary<String,Any>] {
        //get context
        let managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        //Retrieve the current Data.
        var listQuotes = [Dictionary<String,Any>]()
        do{
            let fetchRequestAsDictionary=NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
            fetchRequestAsDictionary.returnsObjectsAsFaults=false
            fetchRequestAsDictionary.relationshipKeyPathsForPrefetching=["fromAuthor.name"]
            let records = try managedContext.fetch(fetchRequestAsDictionary)
            
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
        
        if (dialog.runModal() == NSModalResponseOK){
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
    //Looks for an object, creates one if there is not one there.
    func findOrCreateEntity(key: String, value: Any, entity: String, moc: NSManagedObjectContext)->NSManagedObject{
        
        //Configire search
        let fetchReq=NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let fetchPredicate = NSPredicate(format: "%K == %@", key, value as! String)
        fetchReq.predicate=fetchPredicate
        
        //Execute fetch
        let managedObject = try! moc.fetch(fetchReq) as! [NSManagedObject]
        if managedObject.count > 0 {
            return managedObject.first as! NSManagedObject
        }
        else {
            return NSEntityDescription.insertNewObject(forEntityName: entity, into: moc)
        }
    }
    
    //Creates a managed Object for the specified class, with the attributes as
    //dictionary and in the moc passed as parameter
    func createManagedObject(attributes:Dictionary<String, Any>, Entity: String, inManagedObjectContext: NSManagedObjectContext)->NSManagedObject{
        
        var newObject: NSManagedObject
        switch Entity {
            case "fromAuthor":
                newObject=findOrCreateEntity(key: "name", value: attributes["name"]!, entity: "Author",  moc:moc)
            case "isAbout":
                newObject=findOrCreateEntity(key: "topic", value: attributes["topic"]!, entity: "Theme", moc:moc)
            case "tags":
                newObject=findOrCreateEntity(key: "tag", value: attributes["tag"]!, entity: "Tag", moc:moc)
            default:
                newObject=findOrCreateEntity(key: "quote", value: attributes["quote"]!, entity: "Quote", moc:moc)
        }
        
        newObject.populateFromDictionary(attributesDictionary: attributes)
        //try!moc.save() //Added this line after error on run due to changing removed object
        return newObject
    }
    
    //Import data from a JSON file
    func importFromJSONV2(pathToFile: URL ){
        
        //Read into Array
        let jsonData = NSData(contentsOf: pathToFile)
        let jsonArray = try! JSONSerialization.jsonObject(with: (jsonData)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        for jsonItem in jsonArray {
            let currItem = jsonItem as! Dictionary<String, Any>
 
            let customObject = createManagedObject(attributes: currItem,
                                                   Entity: "Quote",
                                                   inManagedObjectContext: moc) as! Quote
            
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
    
    //Only does one level with recursivity. TO DO: Figure out how to remove that constraint.
    func convertToDictionary() -> Dictionary<String, Any>{
        
        //Get Attributes of object into a dictionary
        let attDict = self.entity.attributeKeys
        var dict=self.dictionaryWithValues(forKeys: attDict)
        
        //Get relationships
        for relationship in self.entity.relationshipsByName {
            let value = self.value(forKey: relationship.key)
            //Case is 1 to 1
            if let oneToOneR = value as? NSManagedObject {
                dict[relationship.key]=oneToOneR.dictionaryWithValuesOfAttributes()
            }
            //Case 1 to Many
            else if let oneToMany = value as? NSSet{
                var dictArray = [[String: Any]]()
                for case let relatedObject as NSManagedObject in oneToMany {
                    dictArray.append(relatedObject.dictionaryWithValuesOfAttributes())
                }
                dict[relationship.key]=dictArray
            }
        }
       return dict
    }
    
    //Returns a dictionary with keys as attributes and values as values.
    func dictionaryWithValuesOfAttributes()->Dictionary<String,Any>{
        return self.dictionaryWithValues(forKeys: self.entity.attributeKeys)
    }
    
    //Populates the attributes from a dictionary
    func populateFromDictionary(attributesDictionary: Dictionary<String, Any>){
        let moc2 = self.managedObjectContext
        
        for case let key as String in attributesDictionary.keys {
            let value = attributesDictionary[key] as! NSObject
            //Check on-to-one relationship
            if value is Dictionary<String, Any> {
                let IE = importExport()
                let relationObject = IE.createManagedObject(attributes: value as! Dictionary<String, Any>,
                                                                Entity: key,
                                                inManagedObjectContext: moc2!) as NSManagedObject
                
                self.setValue(relationObject, forKeyPath: key)
            }
        
            //Check one-to-many relationship
            else if value is NSArray {
                let objectSet = NSSet()
                let IE = importExport()
                for arrayItem in value as! NSArray {
                    let setItem = IE.createManagedObject(attributes: arrayItem as! Dictionary<String, Any>,
                                                         Entity: key, inManagedObjectContext: moc2!) as NSManagedObject
                    objectSet.adding(setItem)
                }
                self.setValue(objectSet, forKeyPath: key)
            }
        
            //Check if it is an attribute
            else{
                if !(value is NSNull) {
                    self.setValue(value, forKey: key)
                }
            }
        }
    }
}



