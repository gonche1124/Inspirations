//
//  Utilities.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/14/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa



//MARK: - NSTreeNodeExtension
extension NSTreeNode {
    //Checks if is Leaf in Themes controller
    func isTheme()->Bool{
        return ((self.representedObject as! NSManagedObject).className == "Theme")
    }
    
    //Checks if is Leaf in Themes controller
    func isAuthor()->Bool{
        return ((self.representedObject as! NSManagedObject).className == "Author")
    }
}

//MARK: - Tags
extension Tags{
    var isLeafTree: Bool {get {return self.subTags!.count>0}}
}

//MARK: - NSManagedObject extensions
extension NSManagedObject {
    
    //var isLeafQuote: Bool {get {return self.className == "Quote"}} //Used in NSTreeController
    
    
    
    //Used to sort elements.
    var sortingKey:String {get {
        switch self.className {
        case "Quote":
            return (self as! Quote).quote!
        case "Author":
            return (self as! Author).name!
        case "Theme":
            return (self as! Theme).topic!
        default:
            return ""
        }
        }}
    
    //Easy way to minimize boilerplate code.
    class func firstWith(predicate:NSPredicate, inContext:NSManagedObjectContext)->NSManagedObject?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.className())
        request.predicate=predicate
        request.fetchLimit=1
        
        guard let results = try! inContext.fetch(request).first as? NSManagedObject else {return nil}
        return results
    }

}

//MARK: - NSDialog
extension NSAlert {
    
    static func showAlert(title: String?, message: String?, style: NSAlert.Style = .critical, withOk: Bool=true, andCancel:Bool=true) -> NSAlert {
        let alert = NSAlert()
        if let title = title {alert.messageText = title}
        if let message = message {alert.informativeText = message}
        if withOk {alert.addButton(withTitle: "Ok")}
        if andCancel {alert.addButton(withTitle: "Cancel")}
        alert.alertStyle = style

        return alert
    }
    
    static func createAlert(title: String?, message: String?, style: NSAlert.Style = .critical, withCancel:Bool=true, andTextField:Bool=false) -> NSAlert {
        let alert = NSAlert()
        if let title = title {alert.messageText = title}
        if let message = message {alert.informativeText = message}
        alert.addButton(withTitle: "Ok")
        if withCancel {alert.addButton(withTitle: "Cancel")}
        if andTextField{
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            textField.placeholderString="Playlist"
            alert.accessoryView=textField
        }
        alert.alertStyle = style
        
        return alert
    }
}

//MARK: - NSViewController
extension NSViewController {
        
    var moc: NSManagedObjectContext {return (NSApp.delegate as! AppDelegate).managedObjectContext} //easy access to moc.
    
}



//Protocols for controllers of tabView
@objc protocol ControllerProtocol{
    @objc optional var currentQuoteController: NSArrayController? {get} //optional variables.
    @objc optional var currentAuthorController: NSArrayController? {get}
    @objc optional var currentThemesController: NSArrayController? {get}
    @objc optional var currentTagsController: NSArrayController? {get}
}

//Protocol for main controller
protocol mainViewController{
    var selectedQuoteController: NSArrayController {get}
    var selectedAuthorController: NSArrayController {get}
}

extension NSViewController: ControllerProtocol {
    var currentQuoteController: NSArrayController?{
        switch self.className {
        case "CocoaBindingsTable":
            return (self as! CocoaBindingsTable).quotesArrayController
        case "QuoteController":
            return (self as! QuoteController).quotesArray
        case "BigViewController":
            return (self as! BigViewController).arrayController
        default:
            return nil
        }
    }
}

//Neccesary if I want to avoid making a class for it.
extension NSSplitViewController{
    override open var representedObject: Any?{
        didSet{
            for child in self.childViewControllers{
                child.representedObject=self.representedObject
            }
        }
    }
}

extension NSTabViewController{
    override open var representedObject: Any?{
        didSet{
            for child in self.childViewControllers{
                child.representedObject=self.representedObject
            }
        }
    }
}



//MARK: - Shared Class
@objcMembers
class SharedItems: NSObject {
   
    //var selectionIndexes: IndexSet = IndexSet()
    var moc:NSManagedObjectContext?
    var mainQuoteController:NSArrayController?
    var authorController:NSArrayController?
    var themeController:NSArrayController?
    var tagController:NSArrayController?
    var playlistController:NSArrayController?
    
}


