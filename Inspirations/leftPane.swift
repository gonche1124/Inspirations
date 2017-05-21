//
//  leftPane.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/10/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class leftPane: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    //Buttons
    
    @IBAction func tableViewClicked(_ sender: NSButton) {
        
        if let contentViewController = parent?.childViewControllers[1] as? NSTabViewController {
            contentViewController.selectedTabViewItemIndex = 0
        }
        
    }
    
    @IBAction func bigViewClicked(_ sender: NSButton) {
        if let contentViewController = parent?.childViewControllers[1] as? NSTabViewController {
            contentViewController.selectedTabViewItemIndex = 1
        }
        
    }
   
    @IBAction func singleViewClicked(_ sender: NSButton) {
        if let contentViewController = parent?.childViewControllers[1] as? NSTabViewController {
            contentViewController.selectedTabViewItemIndex = 2
        }
    }
    
    @IBAction func arrayControllerButton(_ sender: NSButton) {
        
        if let contentViewController = parent?.childViewControllers[1] as? NSTabViewController {
            contentViewController.selectedTabViewItemIndex = 3
        }
    }
    
    
}
