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
        
        self.doneButton.title=doneButtonText
        
//        if let selectedObjects=selectedManagedObjects{
//            quoteController.content=selectedObjects
//            quoteController.addSelectedObjects(selectedObjects)
//            if let tagsArray = selectedObjects.first?.hasTags?.allObjects as NSArray?{
//                tagsTokenField.objectValue = tagsArray
//            }
//            
//        }
    }
    
    //Set the Button as the first responder (Highlighted item).
    override func viewWillAppear() {
        super.viewWillAppear()
        self.doneButton.window?.makeFirstResponder(doneButton)
    }
    
    //MARK: - Variables
    //Variables
    var selectedManagedObjects:[Quote]!
    var selectionIndexes:IndexSet!
    var doneButtonText:String!
    
    //Outlets
    @IBOutlet weak var doneButton: NSButton!    
    @IBOutlet var tagController: NSArrayController!
    @IBOutlet weak var quoteController: NSArrayController!
    @IBOutlet weak var tagsTokenField: NSTokenField!
    

    //MARK: - Actions
    //Pushed the Done Button
    @IBAction func cancelChanges(_ sender: NSButton) {
        
        self.moc.rollback()
        dismiss(self)
        
    }
    //REVIEW TO MAKE SURE IT WOTKS
    @IBAction func pushDoneButton(_ sender: Any) {
        //save

        do {
            try moc.save()
            dismiss(self)
        }catch{
            print("Unable to save the data")
            dismiss(self)
        }
        
    }
}

//MARK: - Extensions
extension AddQuote: NSTokenFieldDelegate{
    
//    //Return the list of possible tags to fill
//    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
//        return (tagController.arrangedObjects as! [Tags]).map({$0.tagName!}).filter({$0.hasPrefix(substring)})
//    }
    
    
    //Called everytime a new Tag is added.
//    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
//
//        //Fetch Tag if it exists already.
//        let currQuote = selectedManagedObjects.first
//        if let existingTag = Tags.firstWith(predicate: NSPredicate(format: "tagName == %@", tokens.first as! String), inContext: moc) as? Tags{
//            existingTag.addToQuotesInTag(currQuote!)
//            return [existingTag]
//        }
//
//        //Create new Tag
//        let newTag = Tags(context:moc)
//        newTag.isLeaf = true
//        newTag.tagName = tokens.first as? String
//        let mainTag = Tags.firstWith(predicate: NSPredicate(format: "tagName == %@", "Tags"), inContext: moc) as? Tags
//        mainTag?.addToSubTags(newTag) //THE OTHERWAY AROUND FOR WHATEVER REASON DIDNT WORK.
//        newTag.isInTag=mainTag //Just testing. This line makes the graph on Tags complete.
//        newTag.addToQuotesInTag(currQuote!)
//        currQuote?.addToHasTags(newTag) //Just testing.
//        return [newTag]
//    }
    
    //SHow string for representedObject.
//    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
//        if let currTag = representedObject as? Tags, let tagName=currTag.tagName {
//            return tagName
//        }
//        return nil
//    }
}



