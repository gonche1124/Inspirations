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
    }
   
    
    //Properties
    var isInfoWindow:Bool=false
    @objc dynamic var isEditing:Bool=false
    @IBOutlet var selectionController: NSArrayController?=nil
    @IBOutlet var tagsController:NSArrayController!
    @IBOutlet var tokenField:NSTokenField!
    
    //Sort descriptors
    @objc dynamic var authorSort:[NSSortDescriptor]=[NSSortDescriptor(key: "name", ascending: true)]
    @objc dynamic var themeSort:[NSSortDescriptor]=[NSSortDescriptor(key: "themeName", ascending: true)]
    
    
    //Actions
    @IBAction func addAndSaveNewQuote(_ sender:NSButton){
        print("To DO")
        try! moc.save()
        //TODO: Make sure that the relationships hold for the 3 array controllers and thenew object.
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
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        if let tagArray=tagsController.arrangedObjects as? Array<Tag>{
            return tagArray.map({$0.name!}).filter({$0.hasPrefix(substring)})
        }
        return nil
    }
    
//    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
//        return tokens
//    }
    
}

