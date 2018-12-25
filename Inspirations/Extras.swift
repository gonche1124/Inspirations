//
//  Extras.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/27/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData
import Cocoa
import WebKit








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

//Extension to array of items where elements conform to protocol identifier.
extension Array where Element:NSUserInterfaceItemIdentification{
    func firstWith(identifier:String)->Element?{
        guard let item=self.first(where:{$0.identifier?.rawValue==identifier}) else {return nil}
        return item
    }
}



//MARK: -
//Class used in NSMenuItems that need to store custom bool value.
class AGC_NSMenuItem: NSMenuItem {
    
    @IBInspectable var agcBool:Bool=false        //Used to define Favorites/Unfavorites in menu call
    @IBInspectable var customURLString:String="" //used for import controller popup item.
    
}

extension String{
    func trimWhites()->String{
        return self.trimmingCharacters(in: .whitespaces)
    }
}

//MARK: - Custom Cell
class AGCCell: NSTableCellView{
    
    //Custom Outlets
    @IBOutlet weak var quoteField: NSTextField?
    @IBOutlet weak var authorField: NSTextField?
    
    
    override var backgroundStyle: NSView.BackgroundStyle {
        willSet {
            if newValue == .dark {
                quoteField?.textColor = NSColor.controlLightHighlightColor
                authorField?.textColor = NSColor.controlHighlightColor
            } else {
                quoteField?.textColor = NSColor.labelColor
                authorField?.textColor = NSColor.controlShadowColor
            }
        }
    }
}






