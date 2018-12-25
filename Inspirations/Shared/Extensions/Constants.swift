//
//  Constants.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation


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


