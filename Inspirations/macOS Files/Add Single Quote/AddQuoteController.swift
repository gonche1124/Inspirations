//
//  AddValue.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 10/29/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class AddQuoteController: NSViewController {

    //Public ENUM that handles the case of what teh controller is actially using.
    public enum CurrentAction{
        case adding, editing, showing, downloading
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editableItems=[quoteTextField, authorComboBox, themeComboBox, favoriteCheck, tokenField ]
        
        // Do view setup here.
        if let currQuote=currQuote {
            self.assignValuesToUIFrom(quote: currQuote)
        }
        //refreshes UI based on state.
        refreshViewState()
    }

    //MARK: - Properties
    //State of the view.
    var viewType:CurrentAction = .adding {
        didSet{
            refreshViewState()
        }
    }
    
    //Variables
    @objc dynamic var authorSort:[NSSortDescriptor]=[NSSortDescriptor(key: "name", ascending: true)]
    @objc dynamic var themeSort:[NSSortDescriptor]=[NSSortDescriptor(key: "themeName", ascending: true)]
    @objc dynamic var currQuote:Quote?
  
    
    //MARK: - Outlets.
    @IBOutlet var selectionController: NSArrayController? //DO we use this?
    @IBOutlet var tagsController:NSArrayController!
    @IBOutlet var tokenField:NSTokenField!
    @IBOutlet var saveButton:NSButton?
    @IBOutlet var cancelButton:NSButton?
    @IBOutlet var quoteTextField:NSTextField!
    @IBOutlet var authorComboBox:NSComboBox!
    @IBOutlet var themeComboBox:NSComboBox!
    @IBOutlet var favoriteCheck: NSButton!
    var editableItems:[NSControl] = [NSControl]()
    
    //MARK: - AutoLayout:
    @IBOutlet var widthConstraint:NSLayoutDimension!
    @IBOutlet weak var rightMargin: NSLayoutConstraint?
    @IBOutlet weak var bottomMargin: NSLayoutConstraint?
    @IBOutlet weak var leftMargin: NSLayoutConstraint?
    @IBOutlet weak var topMargin: NSLayoutConstraint?
    
    
    
    // MARK: - Actions
    ///Called when the users want to edit a quote.
    @IBAction func editQuote(_ sender:NSButton){
        //TODO: Only works for 1 entity, figure out how to do it for multiple.
        viewType = .editing
    }
    
    //Called when the suers wants to save the changes of the selected quote.
    @IBAction func updateQuote(_ sender:NSButton){
        if isInterfaceValid() {
            getValuesFromUIAndAssignTo(quote: currQuote)
            viewType = .showing
        }
    }
    
    ///Ads a new quote based on the values of the UI. Assumes they all exist.
    @IBAction func addNewQuote(_ sender:NSButton){
        if isInterfaceValid() {
            let newQuote=NSEntityDescription.insertNewObject(forEntityName: Entities.quote.rawValue, into: moc) as! Quote
            getValuesFromUIAndAssignTo(quote: newQuote)
            switch viewType {
            case .downloading:
                self.view.window?.close()
            default:
                self.dismiss(self)
            }
        }
    }
    
    ///Cancels any edits that the user might have done.
    @IBAction func cancelsEdits(_ sender:NSButton){
        switch viewType {
        case .downloading:
           self.view.window?.close()
        default:
            self.dismiss(self)
        }
    }
    
    //MARK: - UI Methods
    ///Refreshes the view with the current state.
    fileprivate func refreshViewState() {
        switch self.viewType {
        case .downloading:
            //Adjust margins
            topMargin?.constant=0
            leftMargin?.constant=0
            bottomMargin?.constant=0
            rightMargin?.constant=0
            saveButton?.title = "Add"
            saveButton?.action = #selector(addNewQuote(_:))
            cancelButton?.isHidden = false
            editableItems.forEach{$0.isEnabled=true}
        case .editing:
            saveButton?.title = "Save"
            saveButton?.action = #selector(updateQuote(_:))
            cancelButton?.isHidden = false
            editableItems.forEach{$0.isEnabled=true}
        case .showing:
            saveButton?.title = "Edit"
            saveButton?.action = #selector(editQuote(_:))
            cancelButton?.isHidden = true
            editableItems.forEach{$0.isEnabled=false}
            saveButton?.isEnabled = true
        case .adding:
            saveButton?.title = "Add"
            saveButton?.action = #selector(addNewQuote(_:))
            cancelButton?.isHidden = true
            editableItems.forEach{$0.isEnabled=true}
        }
    }
    
    ///Validates that the interface can be added or updated.
    fileprivate func isInterfaceValid()->Bool {
        //Checks for value in the quote.
        if quoteTextField.stringValue.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted).isEmpty {
            let alert = NSAlert.init(for: .quoteField)
            alert.runModal()
            return false
        }
        //Checks author combo box.
        if authorComboBox.stringValue.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted).isEmpty {
            let alert = NSAlert.init(for: .author)
            alert.runModal()
            return false
        }
        
        //Checks theme.
        if themeComboBox.stringValue.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted).isEmpty {
            let alert = NSAlert.init(for: .theme)
            alert.runModal()
            return false
        }
        return true
    }
    
    ///Completes the creation/Update of a quote passed as a parameter based on the values of the UI
    fileprivate func getValuesFromUIAndAssignTo(quote:Quote?){
        quote?.quoteString=quoteTextField.stringValue
        quote?.isFavorite=Bool.init(favoriteCheck.state.rawValue != 0)
        quote?.from=Author.foc(named: authorComboBox.stringValue, in: moc)
        //quote?.from=Author.firstOrCreate(inContext: moc, withAttributes: ["name":authorComboBox.stringValue], andKeys: ["name"])
        quote?.isAbout=Theme.foc(named: themeComboBox.stringValue, in: moc)
        //quote?.isAbout=Theme.firstOrCreate(inContext: moc, withAttributes: ["themeName":themeComboBox.stringValue], andKeys: ["themeName"])
        if let currTags = self.tokenField.objectValue as? [Tag]{
            quote?.addToIsTaggedWith(NSSet.init(array: currTags))
        }
        //saveMainContext()
    }
    
    /// Fills the UI based on the quote passed as parameter.
    fileprivate func assignValuesToUIFrom(quote:Quote){
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
    
    //1
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let tagInstance=representedObject as? Tag else {return nil}
        return tagInstance.name
    }
    //
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any? {
        let myPredicate=NSPredicate(format:"name == %@ AND isRootItem == NO",editingString)
        return Tag.foc(named: editingString, in: moc)
//        if let existingTag = Tag.firstWith(predicate: myPredicate, inContext: moc){return existingTag}
//        let newTag = Tag.init(named: editingString, inMOC: moc)
//        return newTag
    }
    
    //Shows completions list under.
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        guard let tagArray=tagsController.arrangedObjects as? Array<Tag>else {return nil}
        return tagArray.map({$0.name}).filter({$0.hasPrefix(substring)}).sorted()
    }
}




