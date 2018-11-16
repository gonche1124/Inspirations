//
//  ImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa
import WebKit

class ImporterController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let webPage = URL.init(string:"https://en.wikiquote.org/wiki/Main_Page")
        webDisplay.load(URLRequest(url: webPage!))
    }
    
    //Properties
    var jsonURL: URL?
    @IBOutlet weak var pathToFile: NSTextField!
    @IBOutlet weak var importProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var fieldName: NSTextField!
    @IBOutlet weak var webDisplay: WKWebView!
    
    //MARK: - Actions
    //Chooses a file.
    @IBAction func chooseFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a .json file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt", "json"];
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                pathToFile.stringValue=result.path
                self.jsonURL = result
            }
        }
    }
    
    //Decodes selected file.
    @IBAction func importSelectedFile(_ sender: Any){
        
        //self.jsonURL = URL(fileURLWithPath: pathToFile.stringValue)
        if pathToFile.stringValue.count > 0{
            
            //create private moc to avoid potential thread errors.
            let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            //privateMOC.mergePolicy=NSMergePolicy.mergeByPropertyObjectTrump
            privateMOC.parent = moc
            
            //Set up the UI for importing
            self.importProgressIndicator.isHidden=false
            self.importProgressIndicator.usesThreadedAnimation=true
            self.importProgressIndicator.startAnimation(nil)
            self.fieldName.isHidden=false
            self.fieldName.stringValue="Loading quotes..."
            
            //Create JSON array object.
            guard let testData = try? Data.init(contentsOf: jsonURL!) else {return} //TODO: print proper information.
            guard let tempDictArray = try? JSONSerialization.jsonObject(with: testData, options: []) else {return}
            guard let dictArrayDirty = tempDictArray as? [[String:Any]] else {return}
            
            //Clean dictionary with right keys:
            //TODO: Check for possible keys before passing.
            self.fieldName.stringValue="Cleaninig quotes..."
            let lookUP=["quote":"quoteString", "topic":"themeName"]
            let dictArray=dictArrayDirty.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
            
            
            //UI
            let totItems=Double(dictArray.count)
            self.importProgressIndicator.stopAnimation(nil)
            self.importProgressIndicator.isIndeterminate=false
            self.importProgressIndicator.minValue=1
            self.importProgressIndicator.maxValue=totItems
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            
            //Import
            print(privateMOC.automaticallyMergesChangesFromParent)
            privateMOC.perform{
                for (i, quoteDict) in dictArray.enumerated(){
                    //Create Entity
                    _=Quote.firstOrCreate(inContext: privateMOC, withAttributes: quoteDict, andKeys: ["quoteString"])
                    //Update UI:
                    DispatchQueue.main.async {
                        self.fieldName.stringValue="Importing \(formatter.string(for: i+1)!) quote out of \(formatter.string(for:totItems)!)"
                        self.importProgressIndicator.increment(by: 1)
                    }
                }
                
                //Save private moc:
                DispatchQueue.main.async {
                    self.fieldName.stringValue="Saving \(formatter.string(for:totItems)!) quotes..."
                    self.importProgressIndicator.isIndeterminate=true
                    self.importProgressIndicator.startAnimation(nil)
                }
                try! privateMOC.save()
                
                //Save main moc:
                DispatchQueue.main.async {try! self.moc.save()}
                
                //Dismiss
                DispatchQueue.main.async {self.dismiss(nil)}
            }
        }
    }
    
    //Import from web page
    @IBAction func importFromWebPage(_ sender:NSButton){
        print("Importing from web page")
        let webPage = URL.init(string:"https://en.wikiquote.org/wiki/Main_Page")
        let testString=try? String.init(contentsOf:webPage! )
        
        //TODO: Parse string of HTML.
        
    }
    
    //Recursively cleans a Dictionary
    func cleanUp(dictionary inDict:[String:Any], mappingTo lookUP:[String:String])->[String:Any]{
        
        var outDictionary=[String:Any]()
        for (key, value) in inDict{
            //value is a dictionary.
            if let valueDict=value as? [String:Any]{
                let newValue=cleanUp(dictionary: valueDict, mappingTo: lookUP)
                outDictionary[lookUP[key] ?? key]=newValue
            }else if let valueArr=value as? [[String:Any]]{
                let newValue=valueArr.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
                outDictionary[lookUP[key] ?? key]=newValue
            }
            else{
                outDictionary[lookUP[key] ?? key]=value
            }
        }
        return outDictionary
        
    }
    
}
