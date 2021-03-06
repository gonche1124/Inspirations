//
//  Smar List Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa


class SmartListController: NSViewController {
    
    ///ENUM that defines the type of action beng performed.
    public enum ActionStatus{
        case editing, inserting
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Sets the formatting dictionary.
        predicateView.rowTemplates.removeAll()
        if let stringsFile = Bundle.main.path(forResource: "PredicateFormatting", ofType: "strings"),
            let strings = try? String(contentsOfFile: stringsFile, encoding: .utf16){
            predicateView.formattingDictionary = strings.propertyListFromStringsFileFormat()
        }
        
        //Add Core Data Rows
        let rows = NSPredicateEditorRowTemplate.templates(forEntity: "Quote", in: moc, includingRelationships: true)
        predicateView.rowTemplates.append(contentsOf:rows)
        let compoundRow=NSPredicateEditorRowTemplate.init(compoundTypes: [.and, .not, .or])
        predicateView.rowTemplates.append(compoundRow)
        predicateView.addRow(nil)
        
        self.predicateScrollView.isHidden=true
        self.quotesFound.isHidden=true
        
        //Configure depending on case:
        switch typeOfAction! {
        case .editing:
            self.nameTextField.stringValue=selectedObject.name
            self.createButton.title="Update"
            self.createButton.action=#selector(updateItemName(_:))
            if let smartList=selectedObject as? QuoteList, let predc=smartList.smartPredicate {
                self.predicateScrollView.isHidden=false
                self.quotesFound.isHidden=false
                self.predicateView.objectValue=predc
            }
        case .inserting:
            self.createButton.title="Create"
            self.createButton.action=#selector(createList(_:))
            if (self.insertItemType == .smartList) {
                self.predicateScrollView.isHidden=false
                self.quotesFound.isHidden=false
            }
        }
    }
    
    //MARK: - Properties
    @IBOutlet weak var nameTextField: NSTextField!{
        didSet{
            print("Did Set with \(self.nameTextField.stringValue)")
        }
    }
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var predicateScrollView: NSScrollView!
    @IBOutlet weak var predicateView: NSPredicateEditor!
    @IBOutlet weak var quotesFound:NSTextField!

    
    //Properties set from parent view Controller
    var selectedObject:LibraryItem!
    var insertItemType:LibraryType?
    var typeOfAction:ActionStatus?
    
    //MARK: - Class methods
    ///Closes the current window if the user cancels.
    @IBAction func closeCurrentWindow(_ sender:NSButton){
        self.dismiss(self)
    }
    
    /// Enabled and called only when the user wants to create a new item with the name of the textfield.
    /// - Note: this gets assigned in ViewDidLoad depending on the caller.
    @IBAction func createList(_ sender: NSButton) {
        //Configure new list.
        let nameOfList = nameTextField.stringValue
        switch insertItemType! {
        case .tag:
            _=Tag.init(named: nameOfList, ofType: .tag, underItem: selectedObject, inContext: moc)
        case .list:
            _=QuoteList.init(named: nameOfList, ofType: .list, underItem: selectedObject, inContext: moc)
        case .folder:
            _=QuoteList.init(named: nameOfList, ofType: .folder, underItem: selectedObject, inContext: moc)
        case .smartList:
            let sl = QuoteList.init(named: nameOfList, ofType: .smartList, underItem: selectedObject, inContext: moc)
            sl?.smartPredicate=predicateView.predicate
        default:
            fatalError("No applicable value for: \(insertItemType!)")
        }
        
        self.saveMainContext()
        self.dismiss(self)
        }
    
    ///Updates list name (and predicate if neccesary) for the selected Item.
    /// - Note: this gets assigned in ViewDidLoad depending on the caller.
    @IBAction func updateItemName(_ sender:NSButton){
        self.selectedObject.name=nameTextField.stringValue
        if let smartList = (selectedObject as? QuoteList), (smartList.smartPredicate != nil) {
            smartList.smartPredicate=predicateView.predicate
        }
        self.saveMainContext()
        self.dismiss(self)
    }
    
    //MARK: - NSpredicate Editor.
    @IBAction func predicatedChanged(_ sender:NSPredicateEditor){
        if let updatedPredicate = predicateView.predicate {
            print(updatedPredicate)
           let totItems = try? Quote.count(in: moc, with: updatedPredicate)
            self.quotesFound.stringValue = "\(totItems ?? 0) items found."
        }
    }
}

/// Extensions to enable and disable the textfield.
extension SmartListController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        self.createButton.isEnabled = !nameTextField.stringValue.isEmpty
    }
}




