//
//  BigViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/28/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class BigViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //quoteLabel.delegate = self
    }
    
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var quoteLabel: NSTextField!
    
    //Configures Text Label.
}

extension BigViewController: NSTextFieldDelegate {
    
    ///// NOT WORKNG
    func textDidChange(_ notification: Notification) {
        print ("test textDidChange")
        print ( "\(notification.name)")
        print ("\(notification.description)")
        print ("\(quoteLabel.stringValue)")
    }
    
}

extension BigViewController: NSTextViewDelegate{
    
}
