//
//  Enums.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/24/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation

//MARK: - ENUMS
///CoreData Entities
enum Entities:String{
    case author="Author"
    case language="Language"
    case quote="Quote"
    case tag="Tag"
    case theme="Theme"
    case library="LibraryItem"
    case collection="QuoteList"
}

///CoreData Library Item list types
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
///CHeck if this is used.
enum Selection:Int{
    case tag = 0
    case list = 1
    case smartList = 2
    case folder = 3
}



