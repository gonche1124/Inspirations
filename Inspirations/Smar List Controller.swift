//
//  Smar List Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class Smar_List_Controller: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBOutlet weak var isSmartList: NSButton!
    
    @IBOutlet weak var createButton: NSButton!
    
    @IBOutlet weak var predicateScrollView: NSScrollView!
    @IBOutlet weak var predicateView: NSPredicateEditor!
    
    @IBAction func showPredicateEditor(_ sender: NSButton) {
    }
    
    @IBAction func createList(_ sender: NSButton) {
    }
}
