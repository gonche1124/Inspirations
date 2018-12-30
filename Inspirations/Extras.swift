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


//MARK: -
//Class used in NSMenuItems that need to store custom bool value.
class AGC_NSMenuItem: NSMenuItem {
    
    @IBInspectable var agcBool:Bool=false        //Used to define Favorites/Unfavorites in menu call
    @IBInspectable var customURLString:String="" //used for import controller popup item.
    
}









