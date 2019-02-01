//
//  Shared Extensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData

//Extension of NSPredicate for easy building
extension NSPredicate{
    
    //String searchs
//    static var pIsFavorite:String = "isFavorite == TRUE"
//    static var pSpelledIn:String = "spelledIn.name CONTAINS [CD] %@"
//    static var pInList:String = "ANY isIncludedIn.name contains [CD] %@"
//    static var pIsRoot:String = "isRootItem == YES"
//    static var pIsTagged:String = "ANY isTaggedWith.name contains [CD] %@"
    
    //Predifened Predicates
    static var favoriteItems:NSPredicate = NSPredicate(format:"isFavorite == TRUE")
    static var rootItems:NSPredicate = NSPredicate(format:"isRootItem == YES")
    static var mainLibrary:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.mainLibrary.rawValue)
    static var favoriteLibrary:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.favorites.rawValue)
    static var rootTag:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootTag.rawValue)
    static var rootMain:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootMain.rawValue)
    static var rootList:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootList.rawValue)
    static var rootLanguage:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootLanguage.rawValue)
    
    ///Predciate to search for main library
    static func getItem(ofType: LibraryType)->NSPredicate?{
        return NSPredicate(format: "libraryTypeValue == %@", ofType.rawValue)
    }
    
    
    //Predciate for left searchfield
    static func leftPredicate(withText:String)->NSPredicate{
        if withText == "" { return NSPredicate.rootItems}
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
            return NSPredicate.favoriteItems
        case .language:
            return NSPredicate(format: "spelledIn.name CONTAINS [CD] %@", libraryItem.name)
        case .list:
            return NSPredicate(format: "ANY isIncludedIn.name contains [CD] %@",  libraryItem.name)
        case .smartList:
            return (libraryItem as? QuoteList)?.smartPredicate!
        case .tag:
            return NSPredicate(format: "ANY isTaggedWith.name contains [CD] %@", libraryItem.name)
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
    
    ///Converts a String to a Boolean Value. Used in NSentityDescription.
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}

//MARK: -
extension NSEntityDescription{
    
    ///Returns dictionary of attributes and Attribute type filtered by USER INFO[searchable]=1
    var attributesByNameForPredicateEditor:[String : NSAttributeType]{
        get{
            let baseDict=self.attributesByName.filter{
                guard let userInfo = $0.value.userInfo, let searchable=userInfo["searchable"] as? String else{return false}
                return searchable.boolValue
                }.mapValues{$0.attributeType}
            return baseDict
        }
    }
    
    ///Returns dictionary of relationships and destiny Entity type filtered by USER INFO[searchable]=1
    var relationshipsByNameForPredicateEditor:[String:String?]{
        get{
            let baseDict=self.relationshipsByName.filter{
                guard let userInfo = $0.value.userInfo, let searchable=userInfo["searchable"] as? String else {return false}
                return searchable.boolValue
                }.mapValues{$0.destinationEntity?.name}
            return baseDict
        }
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


