//
//  Extras.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/27/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation

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

//Notification extensions
extension Notification.Name {
    static let selectedViewChanged = Notification.Name("selectedViewChanged")
    static let leftSelectionChanged = Notification.Name("leftSelectionChanged")
    static let selectedRowsChaged = Notification.Name("selectedRowsChaged")
}

//Extension of NSPredicate for easy building
extension NSPredicate{
    
    //String searchs
    static var pIsFavorite:String = "isFavorite == TRUE"
    static var pSpelledIn:String = "isSpelledIn.name CONTAINS [CD] %@"
    static var pInList:String = "ANY isIncludedIn.name contains [CD] %@"
    static var pIsRoot:String = "isRootItem == YES"
    static var pIsTagged:String = "ANY isTaggedWith.name contains [CD] %@"
    
    //Predciate for left searchfield
    static func leftPredicate(withText:String)->NSPredicate{
        if withText == "" { return NSPredicate(format: pIsRoot)}
        return NSPredicate(format: "(name contains [CD] %@ AND isRootItem=NO)", withText)
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
            return ((libraryItem as? QuoteList)?.smartPredicate as? NSPredicate)!
        case LibraryType.tag.rawValue:
            return NSPredicate(format: pIsTagged, libraryItem.name!)
        case LibraryType.mainLibrary.rawValue:
            return NSPredicate(value: true)
        default:
            return nil
        }
    }
}


//TODO: Implement protocols to simplify code.
//protocol MyProtocol {
//    static var sortingKey:String{get}
//}
//
//extension MyProtocol where Self:LibraryItem{
//    static var sortingKey:String{
//        return self.name
//    }
//}


