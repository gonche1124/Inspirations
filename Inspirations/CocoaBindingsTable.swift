//
//  CocoaBindingsTable.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/19/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Foundation
import Cocoa

class CocoaBindingsTable: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Variables
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
}
