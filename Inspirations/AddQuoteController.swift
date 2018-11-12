//
//  AddValue.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 10/29/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa
//TODO: Figure out how to handle saving when a new author/topic is added.
class AddQuoteController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if !isInfoWindow {
            
            //Unbind to add manually.
            self.quoteTextField.unbind(.value)
            self.authorComboBox.unbind(.value)
            self.themeComboBox.unbind(.value)
            self.tokenField.unbind(.value)
            self.favoriteCheck.unbind(.value)
            
            //Enable editing
             self.isEditing=true
        }
        self.saveButton.title = isInfoWindow ? "Edit":"Add"
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if !isInfoWindow {
            //Unbind to add manually.
            self.quoteTextField.unbind(.value)
            self.authorComboBox.unbind(.value)
            self.themeComboBox.unbind(.value)
            self.tokenField.unbind(.value)
            self.favoriteCheck.unbind(.value)
            //Enable editing
            //self.isEditing=true
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if !isInfoWindow {
            //Unbind to add manually.
            self.quoteTextField.unbind(.value)
            self.authorComboBox.unbind(.value)
            self.themeComboBox.unbind(.value)
            self.tokenField.unbind(.value)
            self.favoriteCheck.unbind(.value)
            //Enable editing
            //self.isEditing=true
        }
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
            self.createInstanceFromInterfaceInfo()
            try! moc.save()
            self.dismiss(self)
        }
       
    }
    
    //Creates an instance with the information in the
    func createInstanceFromInterfaceInfo()->Quote?{
        //Perform checks of valid info
        let currQuote=NSEntityDescription.insertNewObject(forEntityName: Entities.quote.rawValue, into: moc) as! Quote
        currQuote.quoteString=quoteTextField.stringValue
        //currQuote.isFavorite=(favoriteCheck.state.rawValue as? Bool)!
        let currAuthor=self.authorComboBox.objectValueOfSelectedItem as? Author
        currQuote.from=currAuthor
        let currTopic=self.themeComboBox.objectValueOfSelectedItem as? Theme
        currQuote.isAbout=currTopic
        let currTags = self.tokenField.objectValue as? [Tag]
        currQuote.addToIsTaggedWith(NSSet.init(array: currTags!))
        return currQuote
    }
    
}

//Mehotds for being a delegate and datasource for combo box.
extension AddQuoteController: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let tagInstance=representedObject as? Tag else {return nil}
        print("displayStringForRepresentedObject")
        return tagInstance.name
    }
    
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any? {
        let myPredicate=NSPredicate(format:"name == %@ AND isRootItem == NO",editingString)
        print("representedObjectForEditing")
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

extension AddQuoteController:NSComboBoxDelegate{
    
//    func comboBoxWillDismiss(_ notification: Notification) {
//        <#code#>
//    }
}

