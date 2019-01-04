//
//  AGC PopOverSegue.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 1/1/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Foundation
import AppKit

/// Custom popover segue to allow to show popovers from selected cells
class AGC_PopOverSegue:NSStoryboardSegue{
    
    ///Variables
    weak var  presentingOutlineView:NSControl?
    var preferredEdge:NSRectEdge = .maxX
    var popOverBehavior:NSPopover.Behavior = .semitransient
    var test:NSView?
    @IBInspectable var myInte:Int=0 //Not showing
    
    //MARK: - Methods
    override func perform() {
        
        if let outlineView=self.presentingOutlineView as? NSOutlineView{
            //Sets the anchor view or the selected Row if available.
            let anchorView=outlineView.view(atColumn: outlineView.clickedColumn,row: outlineView.clickedRow, makeIfNecessary: false) ?? outlineView
            
            //Presents popover
            let srcController = sourceController as! NSViewController
            srcController.present(destinationController as! NSViewController, asPopoverRelativeTo: anchorView.bounds, of: anchorView, preferredEdge: self.preferredEdge, behavior: self.popOverBehavior)
        }
    }
}
