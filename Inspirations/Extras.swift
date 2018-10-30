//
//  Extras.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/27/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData
import Cocoa

//MARK: - ENUMS
//CoreData Entities
enum Entities:String{
    case author="Author"
    case language="Language"
    case quote="Quote"
    case tag="Tag"
    case theme="Theme"
    case library="LibraryItem"
    case collection="QuoteList"
}

//CoreData list types
enum LibraryType:String{
    case tag="tagImage"
    case folder="folderImage"
    case language="languageImage"
    case smartList="smartListImage"
    case list="listImage"
    case favorites="favoritesImage"
    case mainLibrary="mainLibraryImage"
    case rootItem="noImage"
}

//NSPopupbutton selection
enum Selection:Int{
    case tag = 0
    case list = 1
    case smartList = 2
    case folder = 3
}

//MARK: - Static Names
let pQuote = "self.quoteString contains [CD] $value"
let pAuthor = "self.from.name contains [CD] $value"
let pTheme = "self.isAbout.themeName contains [CD] $value"
let pAll = pQuote + " OR " + pAuthor + " OR " + pTheme

//Notification extensions
extension Notification.Name {
    static let selectedViewChanged = Notification.Name("selectedViewChanged")
    static let leftSelectionChanged = Notification.Name("leftSelectionChanged")
    static let selectedRowsChaged = Notification.Name("selectedRowsChaged")
}


//MARK:- NSPredicates

//Extension of NSPredicate for easy building
extension NSPredicate{
    
    //String searchs
    static var pIsFavorite:String = "isFavorite == TRUE"
    static var pSpelledIn:String = "spelledIn.name CONTAINS [CD] %@"
    static var pInList:String = "ANY isIncludedIn.name contains [CD] %@"
    static var pIsRoot:String = "isRootItem == YES"
    static var pIsTagged:String = "ANY isTaggedWith.name contains [CD] %@"


    
    //Predciate for left searchfield
    static func leftPredicate(withText:String)->NSPredicate{
        if withText == "" { return NSPredicate(format: pIsRoot)}
        return NSPredicate(format: "(name contains [CD] %@ AND isRootItem=NO)", withText)
    }
    
    //Array Controller String
    static func mainPredicateString()->String{
        return  pQuote + " OR " + pAuthor + " OR " + pTheme
    }
    
    //Predicate for main table
    static func mainFilter(withString:String)->NSPredicate {
        if withString=="" {return NSPredicate(value: true)}
        return NSPredicate(format: "quoteString contains [CD] %@ OR from.name contains [CD] %@ OR isAbout.themeName contains [CD] %@", withString, withString, withString)
    }
    
    //Predicate for selected left item
    static func predicateFor(libraryItem:LibraryItem)->NSPredicate? {
        switch libraryItem.libraryType {
        case LibraryType.favorites.rawValue:
            return NSPredicate(format: pIsFavorite)
        case LibraryType.language.rawValue:
            return NSPredicate(format: pSpelledIn, libraryItem.name!)
        case LibraryType.list.rawValue:
            return NSPredicate(format: pInList,  libraryItem.name!)
        case LibraryType.smartList.rawValue:
            return (libraryItem as? QuoteList)?.smartPredicate!
        case LibraryType.tag.rawValue:
            return NSPredicate(format: pIsTagged, libraryItem.name!)
        case LibraryType.mainLibrary.rawValue:
            return NSPredicate(value: true)
        default:
            return nil
        }
    }
}



//TODO: Figure out how to make this conform to NSManagedObvject instead of Quote
class GFetchResultsController<T: Quote>:NSFetchedResultsController<Quote>{
    var delegatedTable:NSTableView?
    var selectedObjects:[Quote]?{
        guard let idx = delegatedTable?.selectedRowIndexes else {return nil}
        return self.fetchedObjects!.objects(atIndexes: idx)
    }
    public convenience init(fetchRequest: NSFetchRequest<Quote>, context: NSManagedObjectContext, _: T.Type) {
        self.init(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}



//MARK: - Native Swift Extensions

//Used to be able to pass an IndexSet as a subscript
extension Array {
    subscript<Indices: Sequence>(indices: Indices) -> [Element]
        where Indices.Iterator.Element == Int {
            let result:[Element] = indices.map({return self[$0]})
            return result
    }
    
    func objects<T:Collection>(atIndexes:T)->[Element]
        where T.Element==Int {
            let result:[Element] = atIndexes.map({return self[$0]})
            return result
    }
}

extension NSAlert{
    static func deleteConfirmationAlert(withTotalItems: Int) -> NSAlert {
        let confirmationD = NSAlert()
        confirmationD.messageText = "Delete Records"
        confirmationD.informativeText = "Are you sure you want to delete the \(withTotalItems) selected Quotes?"
        confirmationD.addButton(withTitle: "Ok")
        confirmationD.addButton(withTitle: "Cancel")
        confirmationD.alertStyle = .warning
        return confirmationD
    }
}

extension NSViewController{
    
    @objc dynamic var moc: NSManagedObjectContext {return (NSApp.delegate as! AppDelegate).managedObjectContext} //easy access to moc.
    
    @objc dynamic var mocBackground: NSManagedObjectContext {
        let tempMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempMoc.parent=self.moc
        return tempMoc
    }
}

extension NSMenu{
    
    //Less verbose to create nsmenuItem with a specified identifier
    func addMenuItem(title:String, action: Selector?, keyEquivalent:String, identifier:String ){
        let newItem = NSMenuItem.init(title: title, action: action, keyEquivalent:keyEquivalent)
        newItem.identifier=NSUserInterfaceItemIdentifier(rawValue: identifier)
        self.addItem(newItem)
    }
    
    //Easy way to fecth item with identifier
    func item(withIdentifier:String)->NSMenuItem?{
        return self.items.first(where: {$0.identifier!.rawValue==withIdentifier})
    }
}

//Class used in NSMenuItems that need to store custom bool value.
class AGC_NSMenuItem: NSMenuItem {
    
    @IBInspectable var agcBool:Bool=false
    
}



