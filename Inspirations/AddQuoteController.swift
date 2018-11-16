//
//  AddValue.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 10/29/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class AddQuoteController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if !isInfoWindow {
            
            //Unbind to add manually.
//            self.quoteTextField.unbind(.value)
//            self.authorComboBox.unbind(.value)
//            self.themeComboBox.unbind(.value)
//            self.tokenField.unbind(.value)
//            self.favoriteCheck.unbind(.value)
            
            //Enable editing and bind button
             self.isEditing=true
            self.saveButton.isEnabled=false
            
        }
        self.saveButton.title = isInfoWindow ? "Edit":"Add"
    }
    
    //Properties
    var isInfoWindow:Bool=false
    @objc dynamic var isEditing:Bool=false
    @IBOutlet var selectionController: NSArrayController?=nil
    @IBOutlet var tagsController:NSArrayController!
    @IBOutlet var tokenField:NSTokenField!
    @IBOutlet var saveButton:NSButton!
    @IBOutlet var quoteTextField:NSTextField!
    @IBOutlet var authorComboBox:NSComboBox!
    @IBOutlet var themeComboBox:NSComboBox!
    @IBOutlet var favoriteCheck: NSButton!
    
    //Sort descriptors
    @objc dynamic var authorSort:[NSSortDescriptor]=[NSSortDescriptor(key: "name", ascending: true)]
    @objc dynamic var themeSort:[NSSortDescriptor]=[NSSortDescriptor(key: "themeName", ascending: true)]
    
    
    //Actions
    @IBAction func addAndSaveNewQuote(_ sender:NSButton){
        if isInfoWindow {
            if isEditing {try! moc.save()}
            sender.title = isEditing ? "Edit":"Save"
            isEditing = !isEditing
            return
        }else{
            if (self.createInstanceFromInterfaceInfo() != nil) {
                try! moc.save()
                self.dismiss(self)
            }
            return
        }
    }
    
    //Creates an instance with the information in the
    func createInstanceFromInterfaceInfo()->Quote?{
        //Perform checks of valid info
        guard let authorName=authorComboBox.objectValueOfSelectedItem as? String else {return nil}
        guard let topicName=themeComboBox.objectValueOfSelectedItem as? String else {return nil}
        
        //Creates Entity
        let currQuote=NSEntityDescription.insertNewObject(forEntityName: Entities.quote.rawValue, into: moc) as! Quote
        currQuote.quoteString=quoteTextField.stringValue
        currQuote.isFavorite=Bool.init(favoriteCheck.state.rawValue != 0)
        currQuote.from=Author.firstOrCreate(inContext: moc, withAttributes: ["name":authorName], andKeys: ["name"])
        currQuote.isAbout=Theme.firstOrCreate(inContext: moc, withAttributes: ["themeName":topicName], andKeys: ["themeName"])
        if let currTags = self.tokenField.objectValue as? [Tag]{
            currQuote.addToIsTaggedWith(NSSet.init(array: currTags))
        }
        return currQuote
    }
    
}

//Mehotds for being a delegate and datasource for combo box.
extension AddQuoteController: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let tagInstance=representedObject as? Tag else {return nil}
        return tagInstance.name
    }
    
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any? {
        let myPredicate=NSPredicate(format:"name == %@ AND isRootItem == NO",editingString)
        if let existingTag = Tag.firstWith(predicate: myPredicate, inContext: moc){return existingTag}
        let newTag = Tag(inMOC: moc, andName: editingString)
        return newTag
    }
    
    //Shows completions list under.
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        guard let tagArray=tagsController.arrangedObjects as? Array<Tag>else {return nil}
        return tagArray.map({$0.name!}).filter({$0.hasPrefix(substring)}).sorted()
    }
    
    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
        print("Should Add")
        return tokens
    }
    
}

extension AddQuoteController:NSTextFieldDelegate{
    
    //TODO: Look below.
    //Handle logic to add Tags and enable button.
    //Add theme or Auhtor if is new when editing.
    func controlTextDidEndEditing(_ obj: Notification) {
        if let UIItem = obj.object as? NSUserInterfaceItemIdentification{
            self.saveButton.isEnabled=[quoteTextField, authorComboBox, themeComboBox].reduce(true, {$0 && $1?.hasValue ?? true})
            if UIItem.identifier?.rawValue=="quoteField"{
                //Useless:
                self.quoteTextField.needsLayout=true
                
                self.quoteTextField.setNeedsDisplay()
                self.view.displayIfNeeded()
            }
        }
        
      
    }
}

