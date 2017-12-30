//
//  BigViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/28/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class BigViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Set up tracking areas.
        let areaN = NSTrackingArea.init(rect: nextButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        nextButton.addTrackingArea(areaN)
        
        let areaP = NSTrackingArea.init(rect: previousButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        previousButton.addTrackingArea(areaP)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        //(self.parent as? ViewController)!.searchQuote2.delegate=self
    }
    
    //VAriables
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    
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

//MARK: - Extensions
extension BigViewController: NSSearchFieldDelegate{
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.arrayController.filterPredicate=nil
        (self.parent as? ViewController)?.updateInfoLabel(parameter: "All")
    }
    
    //Gets called everytime a user searches a character.
    override func controlTextDidChange(_ obj: Notification) {
        let searchString = (obj.object as? NSSearchField)!.stringValue
        if searchString != "" {
            self.arrayController.filterPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@",searchString)
            self.arrayController.setSelectionIndex(1)
            (self.parent as? ViewController)?.updateInfoLabel(parameter: (self.arrayController.arrangedObjects as! NSArray).count)
        }
    }
}

