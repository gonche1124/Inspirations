//
//  Shared Extensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData
import Cocoa

//Extension of NSPredicate for easy building
extension NSPredicate{
    
    //Predifened Predicates
    static var favoriteItems:NSPredicate = NSPredicate(format:"isFavorite == TRUE")
    static var rootItems:NSPredicate = NSPredicate(format:"isRootItem == YES")
    static var mainLibrary:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.mainLibrary.rawValue)
    static var favoriteLibrary:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.favorites.rawValue)
    static var rootTag:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootTag.rawValue)
    static var rootMain:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootMain.rawValue)
    static var rootList:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootList.rawValue)
    static var rootLanguage:NSPredicate = NSPredicate(format:"libraryTypeValue == %@", LibraryType.rootLanguage.rawValue)
    
    /// Predicate to search for library items by type
    /// - parameter ofType: Library type item.
    /// - note: it has to be one of the standard items.
    convenience init(forItem: LibraryType) {
        self.init(format: "libraryTypeValue == %@", argumentArray: [forItem.rawValue])
    }
    
    /// Initializes a predicate for the left view base on the search field.
    /// - parameter fromLeftSearchField: Search field form the left view controller used in the NSOutlineView.
    convenience init(fromLeftSearchField searchField:NSSearchField) {
        self.init(format:"(name contains [CD] %@ AND isRootItem=NO)", argumentArray: [searchField.stringValue])
    }
    
    /// Initializes a search for the quote with a given text for the Theme path.
    /// - parameter forThemeWithText: text that the user is using.
    convenience init(forThemeWithText textToSearch:String) {
        self.init(format: "isAbout.themeName contains [CD] %@", argumentArray: [textToSearch])
    }
    
    /// Initializes a search for the quote with a given text for the Author path.
    /// - parameter forAuthorWithText: text that the user is using.
    convenience init(forAuthorWithText textToSearch:String) {
        self.init(format: "from.name contains [CD] %@", argumentArray: [textToSearch])
    }
    
    /// Initializes a search for the quote with a given text for the Quote path.
    /// - parameter forQuoteWithText: text that the user is using.
    convenience init(forQuoteWithText textToSearch:String) {
        self.init(format: "quoteString contains [CD] %@", argumentArray: [textToSearch])
    }
}

//MARK: -
extension NSCompoundPredicate {
    /// Initializes a compund predciate with the given text for all the paths.
    /// - parameter ORcompundWithText: text to search.
    convenience init(ORcompundWithText textToSearch:String) {
        self.init(orPredicateWithSubpredicates: [NSPredicate(forThemeWithText: textToSearch),
                                                 NSPredicate(forAuthorWithText: textToSearch), NSPredicate(forAuthorWithText: textToSearch)])
    }
}

//MARK: - 
extension String{
    /// Removes whitespace on both ends.
    func trimWhites()->String{
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    ///Converts a String to a Boolean Value. Used in NSentityDescription.
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}

//MARK: - NSEntityDescription
extension NSEntityDescription{
    
    /// Returns the predciate for the key used in FOC method
    /// - parameter name: Name of the entity to look for.
    /// - note: Used in the First or Create method to fetch entities by name.
    func predicate(with name:String)->NSPredicate?{
        if let K = self.attributesByName.first(where: {$0.value.userInfo?.keys.contains("FOC") ?? false})?.key {
            return NSPredicate(format: "%K = %@", K, name)
        }
        return nil
    }
    
    
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
//Used to be able to pass an IndexSet as a subscript
extension Array {
//    subscript<Indices: Sequence>(indices: Indices) -> [Element]
//        where Indices.Iterator.Element == Int {
//            let result:[Element] = indices.map({return self[$0]})
//            return result
//    }
    
    func objects<T:Collection>(atIndexes:T)->[Element]
        where T.Element==Int {
            let result:[Element] = atIndexes.map({return self[$0]})
            return result
    }
}


//extension NSFetchedResultsController{
//    @objc func blablabla(at indexSet:IndexSet)->[ResultType]{
//        return indexSet.map{self.object(at: IndexPath(item: $0, section: 0))}
//    }
//
//}
//extension NSFetchedResultsController where ResultType == NSFetchRequestResult{
//    @objc func objects(for rows:IndexSet)->[ResultType]{
//        return rows.map{IndexPath(item: $0, section: 0)}.map{self.object(at: $0)}
//    }
//}
//extension NSFetchedResultsController{
//    @objc func objects(for rows:IndexSet)->[Any]{
//
//        var outArray:[ResultType]=[ResultType]()
//        let rr = rows.map({IndexPath(item: $0, section: 0)})
//        for item in rr {
//            outArray.append(self.object(at: item))
//        }
//        return outArray
////        for (_, index) in indexSet.makeIterator(){
////            let path = IndexPath(item: index, section: 0)
////            outArray += self.object(at: path)
////        }
//        //return indexSet.map({self.object(at: <#T##IndexPath#>)})
//        //return [self.object(at: IndexPath(item: 1, section: 0))]
//    }
//}

