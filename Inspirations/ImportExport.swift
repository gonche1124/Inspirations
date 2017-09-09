//
//  ImportExport.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/31/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa
import Sync



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
    
    //Returns an author (new or existing) depending on the value passed.
    func findOrCreateObject(authorName: String)->NSManagedObject {
        
        //Find object
        //let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let authorFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Author")
        let authorPredicate = NSPredicate(format: "name == %@", authorName)
        authorFetch.predicate = authorPredicate
        
        //Execute fetch
        do {
            let existingAuthor = try moc.fetch(authorFetch) as! [Author]
            if existingAuthor.count > 0 {
                return existingAuthor.first!
            }
            else {
                let returnedAuthor = Author(context: moc)
                returnedAuthor.name = authorName
                return returnedAuthor
            }
        }
        catch {
            fatalError(error as! String)
        }
    }
    
    //Creates a managed Object for the specified class, with the attributes as
    //dictionary and in the moc passed as parameter
    func createManagedObject(attributes:Dictionary<String, Any>, Entity: String, inManagedObjectContext: NSManagedObjectContext)->NSManagedObject{
        
        print("createManagedObject: \(Entity)")
        
        var newObject: NSManagedObject
        switch Entity {
            case "fromAuthor":
                newObject=Author(context: moc)
            case "isAbout":
                newObject=Theme(context: moc)
            case "tags":
                newObject=Tags(context: moc)
            default:
                newObject=Quote(context:moc)
        }
        
        /*
        if Entity == "Quote" {
            newObject = Quote(context: moc)
        }
        else if Entity == "fromAuthor" {
            newObject = Author(context: moc)
        }
        else if Entity == "isAbout" {
            newObject = Theme(context: moc)
        }
        else if Entity == "tags" {
            newObject = Tags(context: moc)
            
        }
        else {
            newObject = Quote(context: moc)
        }
 */
        newObject.populateFromDictionary(attributesDictionary: attributes)
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
            
            try! moc.save()
            
        }
    }
        //do{
            //let jsonArray = try JSONSerialization.jsonObject(with: (jsonData)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray
            //This code is not working!!!!
            
            /*
            do{
                let jsonArray2 = try JSONSerialization.jsonObject(with: (jsonData)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                print ("The JSON array is:")
                print (jsonArray2.object(at: 2))
                print (jsonArray2.firstObject)
                //print ("is type Array: \(jsonArray2.isKind(of: Array as! AnyClass))")
                //print ("is type Dictionary: \(jsonArray2.isKind(of: Dictionary))")
                print ("FInished printing JSON")
            }
            catch{
                print ("Unable to load the data")
                print(error)
            }
            */
            
            //Iterate over evey item adding a NSMAnagedObject
            /*
           let jsonArray3 = ["a", "b", "c"]
            for jsonItem in jsonArray3 {
                
                let currItem = jsonItem as! Dictionary<String, Any>
                print(currItem)
                print("The keys are: \(currItem.keys)")
                print ("The values are: \(currItem.values)")
                
                //Test
                let customObject = createManagedObject(attributes: currItem,
                                                       Entity: "Quote",
                                        inManagedObjectContext: moc)
                
                try! moc.save()
                
                
                /*
                //Create ManagedObjects
                let theAuthor = findOrCreateObject(authorName: currItem.value(forKey: "Author") as! String) as! Author
                let theQuote = Quote(context: moc)
                let theThemes = Theme(context: moc)
                let theTags = Tags(context: moc)
                
                //Configure the items
                //theAuthor.name = currItem.value(forKey: "Author") as? String
                theQuote.quote = currItem.value(forKey: "Quote") as? String
                theQuote.isFavorite = [true, false].randomElement() 
                theThemes.topic = currItem.value(forKey: "Topics") as? String
                theTags.tag = ["Favorite", "Top 25", "Inspirational"].randomElement()
                //theQuote.isAbout = NSSet(object: theThemes)
                theQuote.fromAuthor = theAuthor
                theQuote.isFavorite = false
                theQuote.isAbout = theThemes
                theQuote.tags = NSSet(object: theTags)
                 */
 
                //Save - Check if tihs is resource-heavy
                //save
                do {
                    //print("The quote is: \(String(describing: theQuote.quote))")
                    try moc.save()
                    //dismiss(self)
                }catch{
                    print("Unable to save the data")
                }
            }
            
        }catch{
            print("Error while parsing JSON: Handle it")
        }
        
    }
 */
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
    //To create
    func populateFromDictionary(attributesDictionary: Dictionary<String, Any>){
        
        for case let key as String in attributesDictionary.keys {
            let value = attributesDictionary[key] as! NSObject
            
            //Check on-to-one relationship
            if value is Dictionary<String, Any> {
                let IE = importExport()
                let relationObject = IE.createManagedObject(attributes: value as! Dictionary<String, Any>,
                                                                        Entity: key, inManagedObjectContext: IE.moc) as NSManagedObject
                
                self.setValue(relationObject, forKeyPath: key) //Check if this works
                print("\(self.entity.managedObjectClassName!): added one to one relatinship for: \(key)")
            }
        
            //Check one-to-many relationship
            else if value is NSArray {
                print("This is a one to Many relatinship")
            }
        
            //Check if it is an attribute
            else{
                
            if  !(value is NSNull) {
                print (value)
                self.setValue(value, forKey: key)
                print("\(self.entity.managedObjectClassName!): Added an attribute \(value) for key \(key)")
            }
            }
            
        
        }
        print ("\(self.entity.managedObjectClassName!): finished populating")
    }
}



