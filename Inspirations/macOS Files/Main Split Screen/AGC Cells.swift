//
//  AGC Cells.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/25/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import AppKit

//MARK: - Custom Cell
class AGCCell: NSTableCellView{
    
    //Custom Outlets
    @IBOutlet weak var quoteField: NSTextField?
    @IBOutlet weak var authorField: NSTextField?
    
    
    override var backgroundStyle: NSView.BackgroundStyle {
        willSet {
            if newValue == .dark {
                quoteField?.textColor = NSColor.controlLightHighlightColor
                authorField?.textColor = NSColor.controlHighlightColor
            } else {
                quoteField?.textColor = NSColor.labelColor
                authorField?.textColor = NSColor.controlShadowColor
            }
        }
    }
}
