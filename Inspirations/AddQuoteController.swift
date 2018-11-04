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
           self.selectionController?.add(nil)
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
        }
        try! moc.save()
        self.dismiss(self)
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
    
//    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
//        return tokens
//    }
    
}

