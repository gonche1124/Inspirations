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
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        (self.parent as? ViewController)!.searchQuote2.delegate=self
    }
    
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet var arrayController: NSArrayController!
    
    override func swipe(with event: NSEvent) {
        (event.deltaX < 0 ) ? arrayController.selectNext(nil):arrayController.selectPrevious(nil)
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

