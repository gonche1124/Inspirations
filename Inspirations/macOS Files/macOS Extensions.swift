//
//  macOS Extensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import AppKit


//MARK: -
extension NSUserInterfaceItemIdentifier {
    static let dataCell = NSUserInterfaceItemIdentifier.init("DataCell")
    static let headerCell = NSUserInterfaceItemIdentifier.init("HeaderCell")
}

//MARK: -
//Extension to array of items where elements conform to protocol identifier.
extension Array where Element:NSUserInterfaceItemIdentification{
    func firstWith(identifier:String)->Element?{
        guard let item=self.first(where:{$0.identifier?.rawValue==identifier}) else {return nil}
        return item
    }
}


//MARK: -
extension NSMenu{
    
    ///Less verbose to create nsmenuItem with a specified identifier
    func addMenuItem(title:String, action: Selector?, keyEquivalent:String, identifier:String ){
        let newItem = NSMenuItem.init(title: title, action: action, keyEquivalent:keyEquivalent)
        newItem.identifier=NSUserInterfaceItemIdentifier(rawValue: identifier)
        self.addItem(newItem)
    }
    
    ///Easy way to fecth item with identifier
    func item(withIdentifier:String)->NSMenuItem?{
        return self.items.firstWith(identifier: withIdentifier)
        //return self.items.first(where: {$0.identifier!.rawValue==withIdentifier})
    }
}

//MARK: -
extension NSTextField{
    //Used fo validation in the UI/ADD to make sure it has a value.
    @objc dynamic var hasValue:Bool{
        get {
            print("Value: \(self.stringValue)")
            let myCharacters=CharacterSet.letters.inverted
            return !self.stringValue.trimmingCharacters(in: myCharacters).isEmpty
        }
    }
    
    
}

//MARK: -
extension NSViewController{
    ///easy access to persistentStore
    var pContainer:NSPersistentContainer{
        return (NSApp.delegate as! AppDelegate).persistentContainer
    }
    
    ///easy access to managed object context.
    @objc dynamic var moc: NSManagedObjectContext {return (NSApp.delegate as! AppDelegate).managedObjectContext}
    
    ///easy access to a background managed object context.
    @objc dynamic var mocBackground: NSManagedObjectContext {
        let tempMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempMoc.parent=self.moc
        return tempMoc
    }
    
    ///Simplifications of do-try-save block.
    func saveMainContext(){
        do { try self.moc.save()} catch  {
            print(error)
        }
    }
    ///Simplifications of do-try-save block (for background thread)
    func saveBackgroundContext(){
        do { try self.mocBackground.save()} catch  {
            print(error)
        }
    }
}

//MARK: -
extension NSAlert{
    convenience init(totalItems:Int, isDeleting:Bool) {
        self.init()
        self.messageText = isDeleting ? "Deletes Records":"Removes Records"
        self.addButton(withTitle: "OK")
        self.addButton(withTitle: "Cancel")
        self.informativeText = "Are you sure you want to " + (isDeleting ? "delete":"remove") + " the \(totalItems) selected Quotes?"
        self.alertStyle = .warning
    }
    
    convenience init(withPopUpFrom:Array<String>, forItem:String, at:Int, of:Int){
        self.init()
        self.messageText="Map the key \(at) of \(of)"
        self.informativeText="Please select the key that should be used to assign the value of: \n\(forItem)"
        self.alertStyle = .informational
        self.addButton(withTitle: "OK")
        self.addButton(withTitle: "Cancel")
        self.showsSuppressionButton=true
        self.suppressionButton?.title="Ignore future keys"
        //Layout:
        let keyPopUp=NSPopUpButton.init(title: "Ignore...", target: nil, action: nil)
        keyPopUp.addItems(withTitles: withPopUpFrom)
        keyPopUp.frame=NSRect(origin: keyPopUp.frame.origin, size: CGSize(width: 200, height: keyPopUp.frame.height))
        keyPopUp.setNeedsDisplay()
        self.accessoryView=keyPopUp
    }
}

//MARK: -
extension NSView{
    ///Recursevely get all views
    func getAllSubViews<T:NSView>()->[T]{
        var subviews=[T]()
        self.subviews.forEach { subview in
            subviews += subview.getAllSubViews() as [T]
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }
}
