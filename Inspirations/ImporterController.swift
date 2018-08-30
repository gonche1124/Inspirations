//
//  ImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class ImporterController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func importSelectedFile(_ sender: Any){
        print("Importing")
        let filePath = NSURL(fileURLWithPath: "/Users/Gonche/Desktop/exportedOnFeb24.txt")
        let decoder = JSONDecoder()
        
    }
    
}
