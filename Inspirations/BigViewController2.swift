//
//  BigViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/28/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class BigViewController2: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Set up tracking areas.
        let areaN = NSTrackingArea.init(rect: nextButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        nextButton.addTrackingArea(areaN)
        nextButton.alphaValue=0
        
        let areaP = NSTrackingArea.init(rect: previousButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        previousButton.addTrackingArea(areaP)
        previousButton.alphaValue=0
        
    }
    
    override func viewWillDisappear() {
        super .viewWillDisappear()
        
        //Show info label
        if let infoLabel = NSApp.mainWindow?.contentView?.viewWithTag(1) as? NSTextField {
            if let hConstraint = infoLabel.constraints.first(where: {$0.identifier=="heightOfLabel"}){
                hConstraint.constant=oldLabelHeight!//24
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //Hide info label.
        if let infoLabel = NSApp.mainWindow?.contentView?.viewWithTag(1) as? NSTextField {
            if let hConstraint = infoLabel.constraints.first(where: {$0.identifier=="heightOfLabel"}){
                oldLabelHeight=hConstraint.constant
                hConstraint.constant=0
            }
        }
                
    }
    
    //VAriables
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    var oldLabelHeight:CGFloat?
    
    //Swipe event detected
    override func swipe(with event: NSEvent) {
        (event.deltaX < 0 ) ? arrayController.selectNext(nil):arrayController.selectPrevious(nil)
    }
    
    //Show/Hide buttons
    override func mouseEntered(with event: NSEvent) {
        nextButton.alphaValue=1
        previousButton.alphaValue=1
    }
    
    override func mouseExited(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 1.0
            nextButton.animator().alphaValue = 0
            previousButton.animator().alphaValue=0
        })
    }
}


