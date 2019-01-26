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
    
    //Predifened Predicates
    static var favoriteItems:NSPredicate = NSPredicate(format:NSPredicate.pIsFavorite)
    static var rootItems:NSPredicate = NSPredicate(format:NSPredicate.pIsRoot)
    
    ///Predciate to search for main library
    static func getItem(ofType: LibraryType)->NSPredicate?{
        return NSPredicate(format: "libraryTypeValue == %@", ofType.rawValue)
    }
    
    
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
    static func predicate(for libraryItem:LibraryItem)->NSPredicate? {
        switch libraryItem.libraryType {
        case .favorites:
            return NSPredicate(format: pIsFavorite)
        case .language:
            return NSPredicate(format: pSpelledIn, libraryItem.name!)
        case .list:
            return NSPredicate(format: pInList,  libraryItem.name!)
        case .smartList:
            return (libraryItem as? QuoteList)?.smartPredicate!
        case .tag:
            return NSPredicate(format: pIsTagged, libraryItem.name!)
        case .mainLibrary:
            return NSPredicate(value: true)
        default:
            return nil
        }
    }
}

//MARK: - 
extension String{
    func trimWhites()->String{
        return self.trimmingCharacters(in: .whitespaces)
    }
}

//MARK: - Native Swift Extensions
//TODO: Figure oit where this is used.
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


