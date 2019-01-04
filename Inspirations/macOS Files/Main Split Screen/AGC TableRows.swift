//
//  AGC TableRows.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/30/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import AppKit


/// Used to set the colors on the left view, changing the selection from blue to custom color.
/// - note: See the following link for more information:
/// https://stackoverflow.com/questions/10595774/nstableview-custom-group-row
class LeftNSTableViewRow:NSTableRowView{
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
//    override func drawSelection(in dirtyRect: NSRect) {
//        if self.selectionHighlightStyle != .none {
//            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
//            NSColor(calibratedWhite: 0.65, alpha: 1).setStroke()
//            NSColor(calibratedWhite: 0.82, alpha: 1).setFill()
//            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
//            selectionPath.fill()
//            selectionPath.stroke()
//            //self.interiorBackgroundStyle = .NSView.inter
//        }
//    }
    
    //Used to avoid changing color of labels in cells.
//    override var interiorBackgroundStyle: NSView.BackgroundStyle{
//        set{}
//        get{
//            return .light
//        }
//    }
//
    override var isEmphasized: Bool {
        set {}
        get {
            return false
        }
    }
//
//    override var selectionHighlightStyle: NSTableView.SelectionHighlightStyle {
//        set {}
//        get {
//            return .regular
//        }
//    }

}
