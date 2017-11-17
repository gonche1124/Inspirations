//
//  AddQuote.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


class AddQuote: NSViewController, NSTextFieldDelegate {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
        //doneButton.isEnabled=false
        quoteField.delegate=self
        
        //Add target methods.
        tagsToken.delegate=self
        print(tagController.arrangedObjects)
        
        
        
        //test
//        let request = NSFetchRequest<Author>(entityName: "Author")
//        request.predicate = NSPredicate(format: "hasQuotes.@count == 0 ")
//        let toDelete = try! moc.fetch(request)
//        print (toDelete)
//        moc.delete(toDelete.first!)
//        try! moc.save()
        
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
    
    
    //Pushed the Done Button
    @IBAction func pushDoneButton(_ sender: Any) {
        
        //Get data
        let quoteT = self.quoteField.stringValue
        let themeT = self.themeField.stringValue //self.themeField.objectValue as? String
        let isFav = self.favoriteQuote.state
        let authorT = self.authorField.stringValue//self.authorField.objectValue as? String
        let tags = self.tagsToken.objectValue as? NSArray
        
        //Get context
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
       

        //Create NSManagedObject
        let authorToAdd = ImEx.findOrCreateEntity(key: "name", value: authorT, entity: "Author", moc: managedContext) as! Author
        authorToAdd.name = authorT

        //let quoteToAdd2 = ImEx.findOrCreateEntity(key: "quote", value: <#T##Any#>, entity: <#T##String#>, moc: <#T##NSManagedObjectContext#>)
        let quoteToAdd = Quote(context: managedContext)
        quoteToAdd.quote=quoteT
        quoteToAdd.isFavorite=Bool(truncating: isFav as NSNumber)
        quoteToAdd.fromAuthor = authorToAdd
        for item in tags! {
            let currTag = Tags(context: moc)
            currTag.tag = item as? String
            quoteToAdd.addToTags(currTag)
        }
        
        //Create Topic
        let themeToAdd=ImEx.findOrCreateEntity(key: "topic", value: themeT, entity: "Theme", moc: managedContext) as! Theme
        //let themeToAdd = Theme(context: managedContext)
        //themeToAdd.topic = themeT
        //quoteToAdd.addToIsAbout(themeToAdd)
        quoteToAdd.isAbout = themeToAdd
        
        //save
        do {
            try managedContext.save()
            dismiss(self)
        }catch{
            print("Unable to save the data")
        }
        
    }
}

extension AddQuote: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return ["Happy"]
        
        //return tagController.arrangedObjects as! NSArray as! [Any]
    }
    
}


