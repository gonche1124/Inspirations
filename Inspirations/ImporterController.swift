//
//  ImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class ImporterController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    //Properties
    var jsonURL: URL?
    @IBOutlet weak var pathToFile: NSTextField!
    @IBOutlet weak var importProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var fieldName: NSTextField!
    
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
            self.fieldName.stringValue="Mapping quotes..."
            
            //Create JSON array object.
            guard let testData = try? Data.init(contentsOf: jsonURL!) else {return} //TODO: print proper information.
            guard let tempDictArray = try? JSONSerialization.jsonObject(with: testData, options: []) else {return}
            guard let dictArrayDirty = tempDictArray as? [[String:Any]] else {return}
            
            //Clean dictionary with right keys:
            //TODO: Better implementation and method of its own.
            let lookUP=["quote":"quoteString"]
            let dictArray=dictArrayDirty.map({ (currenDict)->[String:Any] in
                var mappedDict = [String: Any]()
                for (key, value) in currenDict{
                    mappedDict[lookUP[key] ?? key]=value
                }
                return mappedDict
            })
            
            //TODO: Check for possible keys.
            //Imports quotes.
            print(dictArray.count)
            privateMOC.perform{
                for (i, quoteDict) in dictArray.enumerated(){
                    //Create Entity
                    let newQuote:Quote=Quote.firstOrCreate(inContext: privateMOC, withAttributes: quoteDict, and: ["quote"])
    
                    //Update UI:
                    DispatchQueue.main.async {
                        self.fieldName.stringValue="Importing \(i) quote out of \(dictArray.count)"
                    }
                }
                
                //Save private moc:
                try! privateMOC.save()
                
                //Save main moc:
                DispatchQueue.main.async {try! self.moc.save()}
                
                //Dismiss
                //DispatchQueue.main.async {self.dismiss(nil)}
            }
            
            
//            let decoder = JSONDecoder()
//            decoder.userInfo[CodingUserInfoKey.managedContext!]=privateMOC
//            decoder.userInfo[CodingUserInfoKey.progressText!]=self.fieldName
            
            //Parse data
//            self.importProgressIndicator.isHidden=false
//            self.importProgressIndicator.usesThreadedAnimation=true
//            self.importProgressIndicator.startAnimation(nil)
//            self.fieldName.isHidden=false
            
//            privateMOC.perform {
//                do {
//                    let quotesImported = try decoder.decode([Quote].self, from: testData)
//                    DispatchQueue.main.async {
//                        self.fieldName.stringValue="Saving \(quotesImported.count) quotes to child moc"
//                    }
//                    //Save
//                    try privateMOC.save()
//                    DispatchQueue.main.async {
//                        self.fieldName.stringValue="Saving \(quotesImported.count) quotes"
//                    }
//                    //Saves to moc in main thread.
//                    self.moc.perform {
//                        do{
//                            try self.moc.save()
//                        }catch{
//                            print("caught MOC: \(error)")
//                        }
//                    }
//
//                    //TODO: Send notification that XXX number of quotes have been imoprted.
//
//                    //Dismiss
//                    DispatchQueue.main.async {
//                        self.dismiss(nil)
//                    }
//                }catch  {
//                    print("caught: \(error)")
//                }
//            }
            
        }
    }
    
}
