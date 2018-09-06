//
//  PrincipalView.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/26/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

//Used to resize and move the panes around. Check to see if is neccesary.
class MySplitController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
   
        
        self.minimumThicknessForInlineSidebars=300
        print(self.minimumThicknessForInlineSidebars)
        
        //Configure Left Item
        self.splitViewItems.first?.automaticMaximumThickness=0.15
        //self.splitViewItems.first?.collapseBehavior = .preferResizingSiblingsWithFixedSplitView
  
        self.splitViewItems.last?.minimumThickness=400
        //self.splitViewItems.first?.minimumThickness=350
        
    }
    
}





