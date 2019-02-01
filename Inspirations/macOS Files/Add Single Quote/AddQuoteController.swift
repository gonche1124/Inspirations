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
        
        self.nonEmptyTextField=[quoteTextField, authorComboBox, themeComboBox]
        
        // Do view setup here.
        if let currQuote=currQuote {
            self.assignValuesToUIFrom(quote: currQuote)
        }

        
        //Set up button.
        isEditing = !isInfoWindow
        saveButton.title = isInfoWindow ? "Edit":"Add"
        saveButton.isEnabled=isInfoWindow
        saveButton.action=isInfoWindow ? #selector(editOrSave(_:)) : #selector(addNewQuote(_:))
        infoLabel.isHidden=true
        cancelButton.isHidden=true
    }

    //MARK: - Properties
    var isInfoWindow:Bool=false
    var nonEmptyTextField:[NSTextField]=[NSTextField]()
    
    @IBOutlet var selectionController: NSArrayController?=nil
    @IBOutlet var tagsController:NSArrayController!
    @IBOutlet var tokenField:NSTokenField!
    @IBOutlet var saveButton:NSButton!
    @IBOutlet var cancelButton:NSButton!
    @IBOutlet var quoteTextField:NSTextField!
    @IBOutlet var authorComboBox:NSComboBox!
    @IBOutlet var themeComboBox:NSComboBox!
    @IBOutlet var favoriteCheck: NSButton!
    @IBOutlet var infoLabel:NSTextField!
    @IBOutlet var widthConstraint:NSLayoutDimension!
    
    //Sort descriptors used in the array controllers.
    @objc dynamic var authorSort:[NSSortDescriptor]=[NSSortDescriptor(key: "name", ascending: true)]
    @objc dynamic var themeSort:[NSSortDescriptor]=[NSSortDescriptor(key: "themeName", ascending: true)]
    
    @objc dynamic var currQuote:Quote?
    @objc dynamic var isEditing:Bool=false
    
    // MARK: - Actions
    @IBAction func editOrSave(_ sender: NSButton){
        //TODO: Only works for 1 entity, figure out how to do it for multiple.
        if !isEditing {
            isEditing=true
            NSAnimationContext.runAnimationGroup({
                $0.duration=0.25
                $0.allowsImplicitAnimation=true
                cancelButton.isHidden=false
                sender.title = "Save"
                self.view.layoutSubtreeIfNeeded()
            })
            return
        }
        currQuote?.quoteString=quoteTextField.stringValue
        getValuesFromUIAndAssignTo(quote: currQuote!)
        isEditing=false
        cancelButton.isHidden=true
        sender.title = "Edit"
    }
    
    ///Ads a new quote based on the values of the UI. Assumes they all exist.
    @IBAction func addNewQuote(_ sender:NSButton){
        let newQuote=NSEntityDescription.insertNewObject(forEntityName: Entities.quote.rawValue, into: moc) as! Quote
        getValuesFromUIAndAssignTo(quote: newQuote)
        self.dismiss(self)
    }
    
    ///Cancels any edits that the user might have done.
    @IBAction func cancelsEdits(_ sender:NSButton){
        self.dismiss(self)
    }
    
    //MARK: -
    ///Completes the creation/Update of a quote passed as a parameter based on the values of the UI
    func getValuesFromUIAndAssignTo(quote:Quote){
        quote.quoteString=quoteTextField.stringValue
        quote.isFavorite=Bool.init(favoriteCheck.state.rawValue != 0)
        quote.from=Author.firstOrCreate(inContext: moc, withAttributes: ["name":authorComboBox.stringValue], andKeys: ["name"])
        quote.isAbout=Theme.firstOrCreate(inContext: moc, withAttributes: ["themeName":themeComboBox.stringValue], andKeys: ["themeName"])
        if let currTags = self.tokenField.objectValue as? [Tag]{
            quote.addToIsTaggedWith(NSSet.init(array: currTags))
        }
        //saveMainContext()
    }
    
    /// Fills the UI based on the quote passed as parameter.
    func assignValuesToUIFrom(quote:Quote){
        quoteTextField.stringValue=quote.quoteString!
        favoriteCheck.state=NSButton.StateValue.init(quote.isFavorite ? 1:0)
        authorComboBox.stringValue=quote.from!.name!
        themeComboBox.stringValue=quote.isAbout!.themeName!
        if let tagArray = quote.isTaggedWith {
            tokenField.objectValue=Array(tagArray)
        }
    }
    
    //TESTING:
    //TODO: Uncomment.
//    override func validateValue(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey inKey: String) throws {
//        Swift.print("\(#function)")
//        Swift.print("inKey \(inKey)")
//    }
}

//MARK: - NSTokenFieldDelegate
extension AddQuoteController: NSTokenFieldDelegate{
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let tagInstance=representedObject as? Tag else {return nil}
        return tagInstance.name
    }
    
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any? {
        let myPredicate=NSPredicate(format:"name == %@ AND isRootItem == NO",editingString)
        if let existingTag = Tag.firstWith(predicate: myPredicate, inContext: moc){return existingTag}
        let newTag = Tag.init(named: editingString, inMOC: moc)
        return newTag
    }
    
    //Shows completions list under.
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        guard let tagArray=tagsController.arrangedObjects as? Array<Tag>else {return nil}
        return tagArray.map({$0.name}).filter({$0.hasPrefix(substring)}).sorted()
    }
    
//    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
//        print("Should Add")
//        return tokens
//    }
    
}

//MARK: - NSTextFieldDelegate
extension AddQuoteController:NSTextFieldDelegate{
    
    func controlTextDidEndEditing(_ obj: Notification) {

        //Configure texfield depending on values.
        if let textField=obj.object as? NSTextField,
            nonEmptyTextField.map({$0.identifier?.rawValue}).contains(textField.identifier?.rawValue){
            
            textField.layer?.borderColor = NSColor.red.withAlphaComponent(0.2).cgColor
            textField.layer?.borderWidth = textField.hasValue ? 0:2
            saveButton.isEnabled=nonEmptyTextField.reduce(true, {$0 && $1.hasValue })
            //saveButton.isEnabled=[quoteTextField, authorComboBox, themeComboBox].reduce(true, {$0 && $1?.hasValue ?? true})
            //infoLabel.isHidden=
        }
    }
}


