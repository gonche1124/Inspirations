//
//  PlaylistController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/1/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class PlaylistController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    //Variables
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    //Outlets
    @IBOutlet var treeArrayController: NSTreeController!
    
}
