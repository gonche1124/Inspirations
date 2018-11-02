//
//  AddValue.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 10/29/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class AddQuoteController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if !isInfoWindow {
           self.selectionController?.add(nil)
        }
    }
    
    //Properties
    var isInfoWindow:Bool=false
    @objc dynamic var isEditing:Bool=false
    @IBOutlet var selectionController: NSArrayController?=nil
    
    //Sort descriptors
    @objc dynamic var authorSort:[NSSortDescriptor]=[NSSortDescriptor(key: "name", ascending: true)]
    @objc dynamic var themeSort:[NSSortDescriptor]=[NSSortDescriptor(key: "themeName", ascending: true)]
    
    
    //Actions
    @IBAction func addAndSaveNewQuote(_ sender:NSButton){
        print("To DO")
        //TODO: Make sure that the relationships hold for the 3 array controllers and thenew object.
        self.dismiss(self)
    }
    
}

//Mehotds for being a delegate and datasource for combo box.
extension AddQuoteController: NSComboBoxDelegate{
    
    
    
}

