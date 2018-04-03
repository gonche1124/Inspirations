//
//  LeftController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/2/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class LeftController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: Any?{
        didSet{
            print ("Represented object was set on Left")
        }
    }
    
    
//    override var representedObject: Any?{
//        didSet{
//            for item in self.childViewControllers{
//                item.representedObject=representedObject
//                for item2 in item.childViewControllers{
//                    item2.representedObject=representedObject
//                }
//            }
//        }
//    }
}
