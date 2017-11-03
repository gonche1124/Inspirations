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
    @IBOutlet weak var themesField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!
    @IBOutlet weak var favoriteQuote: NSButton!
    
    
    fileprivate lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    
    //Pushed the Done Button
    @IBAction func pushDoneButton(_ sender: Any) {
        //Add save quote later
        
        //Fetch data
        let quoteT = self.quoteField.stringValue
        let authorT = self.authorField.stringValue
        let themeT = self.themesField.stringValue
        let isFav = self.favoriteQuote.state
        
        //Get context
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
       

        //Create NSManagedObject
        //let authorToAdd = Author(context: managedContext)
        let authorToAdd = self.findOrCreateObject(authorName: authorT) as! Author

        
        //authorToAdd.firstName=authorT
        
        let quoteToAdd = Quote(context: managedContext)
        quoteToAdd.quote=quoteT
        quoteToAdd.isFavorite=Bool(truncating: isFav as NSNumber)
        quoteToAdd.fromAuthor = authorToAdd
        
        //Create Topic
        let themeToAdd = Theme(context: managedContext)
        themeToAdd.topic = themeT
        //quoteToAdd.addToIsAbout(themeToAdd)
        
        //save
        do {
            try managedContext.save()
            dismiss(self)
        }catch{
            print("Unable to save the data")
        }
        
    }
    
    //Finds or create the object that the user input
    func findOrCreateObject(authorName: String)->NSManagedObject {
        
        //Find object
        let moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
        let authorFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Author")
        let authorPredicate = NSPredicate(format: "name == %@", authorName)
        authorFetch.predicate = authorPredicate
        
        //Execute fetch
        do {
            let existingAuthor = try moc.fetch(authorFetch) as! [Author]
            
            if existingAuthor.count > 0 {
                print("Record already exists")
                return existingAuthor.first!
            }
            else {
                print("Had to create a new record")
                let returnedAuthor = Author(context: moc)
                returnedAuthor.name = authorName
                return returnedAuthor
            }
            
        }
        catch {
            fatalError(error as! String)
        }
    }
            
            
       
        
        

        
}


