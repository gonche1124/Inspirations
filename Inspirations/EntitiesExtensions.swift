//
//  EntitiesExtensions.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation

//MARK: - Quote
extension Quote{
    
    //Delete any childless entities
    public override func prepareForDeletion() {
     
        //Check if it is the last entity from author
        if let author = self.fromAuthor, author.hasQuotes?.count == 1 {
            managedObjectContext?.delete(author)
        }
        
        //Check if it is the last entity of theme.
        if let theme = self.isAbout, theme.fromQuote?.count == 1 {
            managedObjectContext?.delete(theme)
        }
        
        //Check if it is the last Quote.
        if let tags = self.hasTags as? Set<Tags> {
            tags.forEach({
                if $0.quotesInTag?.count == 1 {managedObjectContext?.delete($0)}
            })
        }
    }
}
