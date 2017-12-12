//
//  AddQuote.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


class AddQuote: NSViewController, NSControlTextEditingDelegate, NSComboBoxDelegate {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
//        doneButton.isEnabled=false
//        quoteField.delegate=self
//        authorField.delegate=self
//        themeField.delegate=self
        
        //Add target methods.
        tagsToken.delegate=self
        
        
        //Testing Observers
        //author2.addObserver(self, forKeyPath: "testing", options: [.old, .new], context: nil)
        
        //addObserver(self, forKeyPath: #keyPath(self.author2), options: [.old, .new], context: nil)
        
    }
    
    
    //Outlets
    @IBOutlet weak var quoteField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!
    @IBOutlet weak var favoriteQuote: NSButton!
    @IBOutlet weak var authorField: NSComboBox!
    @IBOutlet weak var themeField: NSComboBox!
    @IBOutlet weak var tagsToken: NSTokenField!
    
    @IBOutlet var tagController: NSArrayController!
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    @objc dynamic lazy var ImEx = importExport()
    
    //called everytime an objects end editing.
    override func controlTextDidEndEditing(_ obj: Notification) {
        //Validate button.
        let bool1 = quoteField.stringValue.count > 2
        let bool2 = authorField.stringValue.count > 2
        let bool3 = themeField.stringValue.count > 2
        doneButton.isEnabled = (bool1 && bool2 && bool3) ? true:false
    }
    
    //Pushed the Done Button
    //REVIEW TO MAKE SURE IT WOTKS
    @IBAction func pushDoneButton(_ sender: Any) {
        
        //Get data
        let quoteT = self.quoteField.stringValue
        let themeT = self.themeField.stringValue
        let isFav = self.favoriteQuote.state
        let authorT = self.authorField.stringValue
        let tags = self.tagsToken.objectValue as? NSArray
       

        //Create NSManagedObject
        let authorToAdd = ImEx.createNSManagedObject(fromDict:["name": authorT, "className": "Author"]) as! Author
        authorToAdd.name = authorT

        //let quoteToAdd2 = ImEx.findOrCreateEntity(key: "quote", value: <#T##Any#>, entity: <#T##String#>, moc: <#T##NSManagedObjectContext#>)
        let quoteToAdd = Quote(context: moc)
        quoteToAdd.quote=quoteT
        quoteToAdd.isFavorite=Bool(truncating: isFav as NSNumber)
        quoteToAdd.fromAuthor = authorToAdd
        if tags != nil {
        for item in tags! {
            let currTag = Tags(context: moc)
            currTag.tag = item as? String
            quoteToAdd.addToTags(currTag)
        }
        }
        
        //Create Topic
        let themeToAdd = ImEx.createNSManagedObject(fromDict: ["className":"Theme", "topic": themeT]) as! Theme
        quoteToAdd.isAbout = themeToAdd
        
        //save
        do {
            try moc.save()
            dismiss(self)
        }catch{
            print("Unable to save the data")
        }
        
    }
}

extension AddQuote: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return ["Happy", "Test", "Work", "Life"]
        
        //return tagController.arrangedObjects as! NSArray as! [Any]
    }
    
}


