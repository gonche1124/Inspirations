//
//  RightController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/26/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class RightController: NSViewController {

    
    //Properties
    @IBOutlet weak var tabContainer: NSView!
    
    @IBOutlet weak var statusTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedTabView(_:)), name: .selectedViewChanged, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(ccc_test(_:)), name: Notification.Name.Tab, object: <#T##Any?#>)
        //NSUserNotificationCenter.default.addObserver(self, forKeyPath:#keyPath(), options: .new, context: nil)
        //NSUserNotificationCenter.default.addObserver(self, forKeyPath: #keyPath(LeftController.listView.it), options: <#T##NSKeyValueObservingOptions#>, context: <#T##UnsafeMutableRawPointer?#>)
       
    }
    
    @IBAction func ccc_test(_ sender:Any){
        print("ccc_test")
    }
    
    //Changes the TAB View.
    @IBAction func changeSelectedTabView(_ sender: Any){
        if let segmentedControl = (sender as? NSNotification)?.object as? NSSegmentedControl{
            if let tabViewController = self.childViewControllers[0] as? NSTabViewController{
                tabViewController.selectedTabViewItemIndex=segmentedControl.selectedSegment //TODO: Check if can sync, if not to make select tab.
            }
            
        }
        print("Test")
        
    }
    
}
