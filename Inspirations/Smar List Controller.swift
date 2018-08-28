//
//  Smar List Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class Smar_List_Controller: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        predicateView.addRow(nil)
        bottomView.isHidden=true
    }
    
    //Properties
    @IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var heightScrollViewPredicate: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var isSmartList: NSButton!
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var predicateScrollView: NSScrollView!
    @IBOutlet weak var predicateView: NSPredicateEditor!
    
    @IBAction func showPredicateEditor(_ sender: NSButton) {
        if sender.state==NSButton.StateValue.on {
            bottomView.isHidden=false
            resizePredicateScrollView(predicateView)
        }
        else {
            bottomView.isHidden=true
        }
    }
    
    //Adjust constraints to show and hide predicate editor.
    func resizePredicateScrollView(_ sender: NSPredicateEditor) {
        let numR = Int(sender.numberOfRows)
        let rowH = Int(sender.rowHeight)
        heightScrollViewPredicate.constant=CGFloat(numR*rowH)
    }
    
    //Anytime there is action on thepredicate.
    @IBAction func predicatedChanged(_ sender: NSPredicateEditor) {
        if isSmartList.state==NSButton.StateValue.on {
            resizePredicateScrollView(sender)
        }
    }
    
    //Creates the new list item.
    @IBAction func createList(_ sender: NSButton) {
        //Configure new list.
        let nameOfList = nameTextField.stringValue
        let newList = NSEntityDescription.insertNewObject(forEntityName: Entities.collection.rawValue, into: moc) as? QuoteList
        newList?.name = nameOfList
        if isSmartList.state==NSButton.StateValue.on {
            newList?.smartPredicate=predicateView.predicate
        }
        //Add it to the parent list.
        let mainList = LibraryItem.firstWith(predicate: NSPredicate(format:"name == 'Lists'"), inContext: moc) as? LibraryItem
        newList?.belongsToLibraryItem=mainList
        
        try! moc.save() //save
        
        //Refresh main list
        //TODO: Rewrite to make compatible with NSSPlitviewController
        //let leftController=NSApp.mainWindow?.contentViewController as? AlternateController2
        //leftController?.listView.reloadData()
        //leftController?.listView.expandItem(nil, expandChildren: true)
    
        self.dismiss(self)
    }
}


