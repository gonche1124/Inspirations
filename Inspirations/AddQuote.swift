//
//  AddQuote.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


class AddQuote: NSViewController, NSComboBoxDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tagsToken.delegate=self
        self.doneButton.title=doneButtonText
        
        if let selectedObjects=selectedManagedObjects{
            quoteController.content=selectedObjects
            quoteController.addSelectedObjects(selectedObjects)
            
        }
        
    }
    
    //Set the Button as the first responder (Highlighted item).
    override func viewWillAppear() {
        super.viewWillAppear()
        self.doneButton.window?.makeFirstResponder(doneButton)
        
    }
    
    //Variables
    var selectedManagedObjects:[Quote]!
    var selectionIndexes:IndexSet!
    var doneButtonText:String!
    
    
    
    //Outlets
    @IBOutlet weak var quoteField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!
    @IBOutlet weak var favoriteQuote: NSButton!
    @IBOutlet weak var authorField: NSComboBox!
    @IBOutlet weak var themeField: NSComboBox!
    @IBOutlet weak var tagsToken: NSTokenField!
    
    @IBOutlet var tagController: NSArrayController!
    @IBOutlet weak var quoteController: NSArrayController!
    

    
    //Pushed the Done Button
    @IBAction func cancelChanges(_ sender: NSButton) {
        
        self.moc.rollback()
        dismiss(self)
        
    }
    //REVIEW TO MAKE SURE IT WOTKS
    @IBAction func pushDoneButton(_ sender: Any) {
        
        //Get data
//        let quoteT = self.quoteField.stringValue
//        let themeT = self.themeField.stringValue
//        let isFav = self.favoriteQuote.state
//        let authorT = self.authorField.stringValue
//        let tags = self.tagsToken.objectValue as? NSArray
//
//
//        //Create NSManagedObject
//        let authorToAdd = NSEntityDescription.insertNewObject(forEntityName: "Author", into: moc) as! Author
//        authorToAdd.name = authorT
//
//        let quoteToAdd = Quote(context: moc)
//        quoteToAdd.quote=quoteT
//        quoteToAdd.isFavorite=Bool(truncating: isFav as NSNumber)
//        quoteToAdd.fromAuthor = authorToAdd
//        if tags != nil {
//        for item in tags! {
//            let currTag = Tags(context: moc)
//            currTag.tagName = item as? String
//            quoteToAdd.addToHasTags(currTag)
//        }
//        }
//
//        //Create Topic
//        let themeToAdd = NSEntityDescription.insertNewObject(forEntityName: "Theme", into: moc) as! Theme
//        themeToAdd.topic = themeT
//        quoteToAdd.isAbout = themeToAdd
        
        let mainTag = Tags.firstWith(predicate: NSPredicate(format: "tagName == %@", "Tags"), inContext: self.moc) as? Tags
        if (doneButtonText=="Add"), let newTags = self.tagsToken.objectValue as? [String]{
            for item in newTags{
                let currTag = Tags(context:self.moc)
                currTag.isLeaf=true
                currTag.tagName = item
                currTag.isInTag=mainTag
                selectedManagedObjects.first?.addToHasTags(currTag)
            }
        }
        
        
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
    
    //Return the list of possible tags to fill
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return (tagController.arrangedObjects as! [Tags]).map({$0.tagName!}).filter({$0.hasPrefix(substring)})
    }
    
}



