//
//  EntitiesExtensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation

//MARK: - Quote
//extension Quote{
//
//    //Delete any childless entities
//    public override func prepareForDeletion() {
//
//        //Check if it is the last entity from author
//        if let author = self.fromAuthor, author.hasQuotes?.count == 1 {
//            managedObjectContext?.delete(author)
//        }
//
//        //Check if it is the last entity of theme.
//        if let theme = self.isAbout, theme.fromQuote?.count == 1 {
//            managedObjectContext?.delete(theme)
//        }
//
//        //Check if it is the last Quote.
//        if let tags = self.hasTags as? Set<Tags> {
//            tags.forEach({
//                if $0.quotesInTag?.count == 1 {managedObjectContext?.delete($0)}
//            })
//        }
//    }
//}

//MARK: - Tags
//extension Tags{
//
//    //Update the smartPredicate when the tagName changes.
//    public override func didChangeValue(forKey key: String) {
//        if key == "tagName" {
//            if self.isInTag?.tagName != "Library"{
//                let predicate = NSPredicate(format: "ANY hasTags.tagName IN %@", self.tagName!)
//                self.smartPredicate = predicate.predicateFormat
//            }
//        }
//    }

    //Used to check if it is a leafTree
  //  var isLeafTree: Bool {get {return self.subTags!.count>0}}
    
    //Used to show the count of the actual
//    public var totalQuotes: Any? {
//        get{
//            self.willAccessValue(forKey: "totalQuotes")
//            let text = self.primitiveValue(forKey: "totalQuotes") as? String
//            self.didAccessValue(forKey: "totalQuotes")
//            return text
//        }
//        set{
//            self.willChangeValue(forKey:"totalQuotes")
//            self.setPrimitiveValue(newValue, forKey: "totalQuotes")
//            self.didChangeValue(forKey: "totalQuotes")
//        }
//    }
    
    
//}
