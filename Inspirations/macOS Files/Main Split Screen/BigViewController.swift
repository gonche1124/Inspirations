//
//  BigViewController.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 3/29/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Cocoa

class BigViewController: NSViewController {

    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    
    
    
    //MARK: - Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    //MARK: - Actions.
    @IBAction func showPrevious(_ sender: NSButton) {
    }
    
    @IBAction func showNext(_ sender: NSButton) {
    }
    
}
