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
    
    //Return an Array with all the Quotes
    func retrieveArrayOfRecords()-> [Dictionary<String,Any>] {
        //get context
        let managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        
        //Retrieve the current Data.
        var listQuotes = [Dictionary<String,Any>]()
        do{
            let fetchRequestAsDictionary=NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
            //fetchRequestAsDictionary.resultType=NSFetchRequestResultType.dictionaryResultType
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
        else {
            print("User canceled")
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
}



