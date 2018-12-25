//
//  Shared Extensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation

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
