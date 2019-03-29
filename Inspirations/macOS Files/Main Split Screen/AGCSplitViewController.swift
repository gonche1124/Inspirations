//
//  AGCSplitViewController.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 3/28/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Cocoa

class AGCSplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("The segue is: \(segue.identifier)")
    }
    
}
