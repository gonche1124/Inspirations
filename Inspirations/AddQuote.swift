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
        //Add target methods.
        tagsToken.delegate=self
    }
    
    
    //Outlets
    @IBOutlet weak var quoteField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!
    @IBOutlet weak var favoriteQuote: NSButton!
    @IBOutlet weak var authorField: NSComboBox!
    @IBOutlet weak var themeField: NSComboBox!
    @IBOutlet weak var tagsToken: NSTokenField!
    
    @IBOutlet var tagController: NSArrayController!
    //@objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    //@objc dynamic lazy var ImEx = importExport()
    
    //called everytime an objects end editing.
    override func controlTextDidEndEditing(_ obj: Notification) {
        //Validate button.
        let bool1 = quoteField.stringValue.count > 1
        let bool2 = authorField.stringValue.count > 1
        let bool3 = themeField.stringValue.count > 1
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
        let authorToAdd = NSEntityDescription.insertNewObject(forEntityName: "Author", into: moc) as! Author
        authorToAdd.name = authorT

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
        let themeToAdd = NSEntityDescription.insertNewObject(forEntityName: "Theme", into: moc) as! Theme
        themeToAdd.topic = themeT
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
        //return ["Happy", "Test", "Work", "Life"]
        return (tagController.arrangedObjects as! [Tags]).map({$0.tag!})
    }
    
}


