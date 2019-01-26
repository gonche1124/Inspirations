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

///Core Data Entities

///CoreData Library Item list types
public enum LibraryType:String{
    //Main cases:
    case tag="tagImage"
    case folder="folderImage"
    case language="languageImage"
    case smartList="smartListImage"
    case list="listImage"
    case favorites="favoritesImage"
    case mainLibrary="mainLibraryImage"
    //Root cases:
    case rootMain="mainNoImage"
    case rootTag="rootTag"
    case rootLanguage="rootLanguage"
    case rootList="rootList"
    
    ///Returns an array with Tags, Folder, SmartList & List.
    static var deletableItems:[LibraryType]{
        return [.tag, .folder, .list, .smartList]
    }
    
    ///Array of root items.
    static var rootItems:[LibraryType]{
        return [.rootTag, .rootList, .rootMain, .rootLanguage]
    }
    
    /// Array of items that cant be change the name.
    static func nonEditableItems()->[LibraryType]{
        return [.rootTag, .rootList, .rootMain, .rootLanguage, .mainLibrary, .favorites]
    }
    
    /// Array of items that can contain a folder.
    static func itemsParentOfFolder()->[LibraryType]{
        return [.folder, .rootTag, .rootList]
    }
}

//NSPopupbutton selection
///CHeck if this is used.
enum Selection:Int{
    case tag = 0
    case list = 1
    case smartList = 2
    case folder = 3
}

/// Used to enable and disabl the right menus
enum AGCMENU:Int{
    case edit, addTag, addList, addSmartList, addFolder
}



