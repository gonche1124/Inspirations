//
//  InfoController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/10/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class InfoController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        test()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//         //self.objectController.bind(.contentObject, to: (NSApp.mainWindow?.contentViewController as! ViewController).VCPlainTable.quotesArrayController, withKeyPath: "selection", options: nil)
//    }
    @objc dynamic lazy var areItemsEditable: Bool = false
    
    @IBAction func makeEditable(_ sender: NSButton) {
        self.areItemsEditable = !self.areItemsEditable
        editButton.title = (areItemsEditable) ? "Save": "Edit"
    }
    
    @IBOutlet weak var editButton: NSButton!
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //Refrence to a specific View controller
    @objc dynamic lazy var currentVC: NSArrayController = (NSApp.mainWindow?.contentViewController as! ViewController).VCPlainTable.quotesArrayController
    
    
    func test (){
        print("wow")
        let viewController = NSApp.mainWindow?.contentViewController as! ViewController
        print (viewController.informationLabel.stringValue)
        //print(self.view.window)
    }
    
}
