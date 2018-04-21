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



