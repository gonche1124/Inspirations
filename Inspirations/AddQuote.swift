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
        authorField.delegate=self
    }
    
    //Outlets
    @IBOutlet weak var quoteField: NSTextField!
    @IBOutlet weak var authorField: NSTextField!
    @IBOutlet weak var ratingField: NSTextField!
    @IBOutlet weak var themesField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!
    
    //Pushed the Done Button
    @IBAction func pushDoneButton(_ sender: Any) {
        //Add save quote later
        
        //Fetch data
        let quoteT = self.quoteField.stringValue
        let authorT = self.authorField.stringValue
        let themeT = self.themesField.stringValue
        
        //Get context
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
       

        //Create NSManagedObject
        let authorToAdd = Author(context: managedContext)
        authorToAdd.firstName=authorT
        
        let quoteToAdd = Quote(context: managedContext)
        quoteToAdd.quote=quoteT
        quoteToAdd.fromAuthor = authorToAdd
        
        //CReate NSSet
        let themeToAdd = Theme(context: managedContext)
        themeToAdd.topic = themeT
        quoteToAdd.isAbout = NSSet(object: themeToAdd)
        
        //save
        do {
            try managedContext.save()
        }catch{
            print("Unable to save the data")
        }
        
        //For testing
        print("\(quoteT) by \(authorT)")
        
    }
    

}
