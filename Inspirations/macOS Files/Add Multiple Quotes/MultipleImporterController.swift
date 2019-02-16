//
//  MultipleImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/22/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


import Cocoa
import WebKit
import SwiftSoup

//Mark: - Parent Import Controller.
class MainImportController:NSViewController{
    
    var myFormat:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        return formatter
    }()
    
    //Outlets.
    @IBOutlet weak var importQuotes:NSButton!
    @IBOutlet weak var progressIndicator:NSProgressIndicator!
    @IBOutlet weak var progressLabel:NSTextField!
    
    //Sets the progress idnicator and labels as enabled, not hidden and animated.
    func showProgress(withLabel:String?=nil, andStarting:Bool=true){
        self.progressIndicator.isHidden=false
        self.progressLabel.isHidden=false
        self.progressIndicator.usesThreadedAnimation=true
        
        if andStarting{
            progressIndicator.startAnimation(nil)
        }
        if let newLabel=withLabel{
            progressLabel.stringValue=newLabel
        }
    }
    
    //TODO: Implement isHidden through KVO for label, progress indicator and layoutconstraints.
    
    //Turns indefinite progress to definite
    func convertIndicatorTodefinate(withItems:Double, andLabel:String?=nil){
        progressIndicator.stopAnimation(nil)
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue=1
        progressIndicator.maxValue=withItems
    }
    
    //used to override the UI parameters.
    override func viewWillAppear() {
        super.viewWillAppear()
        self.progressIndicator.isHidden=true
        self.progressLabel.isHidden=true
    }
    
    //Save and close
    @IBAction func saveAndClose(_ sender:Any){
        try! moc.save()
        self.view.window?.close()
    }
    
}
//MARK: -
class FileImporter: MainImportController {
    
    //private variables
    fileprivate var fileURL:URL?
    
    //Outlets
    @IBOutlet weak var pathField:NSTextField!
    
    //Gets the filepath and saves it to the NSTextfield
    @IBAction func chooseFile(_ sender:NSButton){
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a .json file";
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt", "json"];
        if (dialog.runModal() == NSApplication.ModalResponse.OK), let result = dialog.url {
            pathField.stringValue=result.path
            fileURL = result
        }
    }
    
    //TODO: Disable import button when no file path selected.
    @IBAction func importQuotesFromJSON(_ sender:NSButton){
        
        //Create the JSON dictionary to Parse.
        guard let dictArrayDirty=getDictionary(fromURL: fileURL!) else {return}
        
        //Set up UI
        showProgress(withLabel: "Loading quotes...", andStarting: true)
        
        //Clean dictionary with right keys:
        //TODO: Check for possible keys before passing.
        //let dictOfKeys=getAllPossibleKeys(dictionaryArray: dictArrayDirty)
        //let lookUP=mapNewKeys(fromSet: dictOfKeys)
        let lookUP=["quote":"quoteString", "topic":"themeName"]
        
        progressLabel.stringValue="Cleaninig quotes..."
        let dictArray=dictArrayDirty.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
        let totItems=dictArrayDirty.count
        self.convertIndicatorTodefinate(withItems: Double(totItems))
        
        //Import
        self.pContainer.performBackgroundTask{ (context) in
            context.undoManager=nil //Turn off undoManager for performance.
            //Create Quotes updating the UI
            for (i, quoteDict) in dictArray.enumerated(){
                guard let qString = quoteDict["quoteString"] as? String else {
                    print("Cant decode the Quote.")
                    continue
                }
                let newQuote = Quote.foc(named: qString, in: context)
                guard let authorDict = quoteDict["fromAuthor"] as? Dictionary<String,Any>, let authorName=authorDict["name"] as? String else {
                    print("Cant decode the author.")
                    continue
                }
                newQuote.from = Author.foc(named: authorName, in: context)
                guard let themeDict = quoteDict["isAbout"] as? Dictionary<String,Any>, let theme = themeDict["themeName"] as? String else {
                    print("Cant decode the Topic.")
                        continue
                }
                newQuote.isAbout = Theme.foc(named: theme, in: context)
                
                //Check for tags or bool
                newQuote.addAttributes(from: quoteDict)
                
                
            
                //Does it run smoother?
                if (i%5==0) {
                    DispatchQueue.main.async {
                        self.progressLabel.stringValue="Importing \(self.myFormat.string(for: i+1)!) quote out of \(self.myFormat.string(for:totItems)!)"
                        self.progressIndicator.increment(by: 5)
                    }
                }
            }
            
            //Save private moc:
            DispatchQueue.main.async {
                self.progressLabel.stringValue="Saving \(self.myFormat.string(for:totItems)!) quotes..."
                self.progressIndicator.isIndeterminate=true
                self.progressIndicator.startAnimation(nil)
            }
            
            //Saves
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            //Dismiss
            DispatchQueue.main.async {self.view.window?.close()}
        }
    }
    
    ///Converts the URL into a JSON dictionary to be able to parse.
    func getDictionary(fromURL:URL)->[[String:Any]]?{
        guard let testData = try? Data.init(contentsOf: fromURL) else{
            print("Could not create data from JSON file")
            return nil
        }
        guard let tempDictArray = try? JSONSerialization.jsonObject(with: testData, options: []) else{
            print("Could not create  JSON Object.")
            return nil
        }
        guard let dictArrayDirty = tempDictArray as? [[String:Any]] else{
            print("could not create dicitonary from JSON Object.")
            return nil
        }
        return dictArrayDirty
    }
    
    /// Recursively cleans a Dictionary, setting keys to existing values and returning a new dictionary.
    /// - parameter dictionary: Dictionary to clean. Usually a JSON dictionary.
    /// - parameter mappingTo: Dictionary used to lookup the keys to be replaced.
    /// - Note: This method is called from the JSON importer to help handle cases where the keys do not
    /// correspond to the core data relationships. It recursevly creates a copy of the input dictionary with the
    /// right keys and the same values.
    func cleanUp(dictionary inDict:[String:Any], mappingTo lookUP:[String:String])->[String:Any]{
        
        var outDictionary=[String:Any]()
        for (key, value) in inDict{
            //value is a dictionary.
            if let valueDict=value as? [String:Any]{
                let newValue=cleanUp(dictionary: valueDict, mappingTo: lookUP)
                outDictionary[lookUP[key] ?? key]=newValue
            }
                //Value is an array of dictrionaries:
            else if let valueArr=value as? [[String:Any]]{
                let newValue=valueArr.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
                outDictionary[lookUP[key] ?? key]=newValue
            }
            else{
                outDictionary[lookUP[key] ?? key]=value
            }
        }
        return outDictionary
    }
    
    /// Gets an array of all the possible keys in the JSON file.
    //TODO: use dot syntaxis for keys.
    func getAllPossibleKeys(dictionaryArray:[[String:Any]])->Set<String>{
        //var outArray=[String]()
        var outSet=Set<String>()
        //Asign keys from current array.
        outSet.formUnion(dictionaryArray.flatMap({$0.keys}))
        
        //Checks if any value is a dictionary and assigns key.
        let valuesDict=dictionaryArray.flatMap({$0.values})
        valuesDict.forEach{ item in
            //Value is a dictionary:
            if let dict=item as? [String:Any]{
                outSet.formUnion(getAllPossibleKeys(dictionaryArray: [dict]))
            }
            //value is an array:
            if let arrayOfDict=item as? [[String:Any]]{
                outSet.formUnion(getAllPossibleKeys(dictionaryArray: arrayOfDict))
            }
        }
        return outSet
    }
    
    /// Asks the user iteratively to define each of the new keys or to ignore.
    /// - parameter fromSet: Set of unique strings that need to be mapped.
    func mapNewKeys(fromSet:Set<String>)->[String:String]{
        //Empty dict.
        var outDict=[String:String]()
        
        //Get valid values properties by name
        let MOM=(NSApp.delegate as? AppDelegate)?.persistentContainer.managedObjectModel
        var listOfEntities=MOM?.entities.flatMap({$0.propertiesByName.keys})
        listOfEntities?.insert("Ignore", at: 0)
        listOfEntities?.sort()
        
        //get values that are not mapped
        let cleanFromSet=fromSet.symmetricDifference(listOfEntities!).intersection(fromSet)
        
        //Ask user for each case, adding it to a dictionary.
        for (n,newKey) in cleanFromSet.enumerated(){
            let newKeyAlert=NSAlert.init(withPopUpFrom: listOfEntities!, forItem: newKey, at: n+1, of:cleanFromSet.count)
            let result=newKeyAlert.runModal()
            if result == .alertFirstButtonReturn{
                if let popButton=newKeyAlert.accessoryView as? NSPopUpButton{
                    outDict[newKey]=popButton.selectedItem?.title
                }
            }
            //Ignore future undefined keys:
            if newKeyAlert.suppressionButton?.state==NSButton.StateValue.on {
                return outDict
            }
        }
        return outDict
    }
}

//MARK: - NSTabViewController
class TabViewImportController:NSTabViewController{

    //Used to center the toolbarItems.
    override func viewWillAppear() {
        super.viewWillAppear()
        if let toolBar = view.window?.toolbar {
            toolBar.insertItem(withItemIdentifier: .flexibleSpace, at: 0)
            toolBar.insertItem(withItemIdentifier: .flexibleSpace, at: 3)
            //toolBar.displayMode = .labelOnly
        }
    }
}

