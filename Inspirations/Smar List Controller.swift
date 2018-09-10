//
//  Smar List Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa


//TODO: Change size to ask first what type of item you want ot add through combobox and remove checkbox.
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
    @IBOutlet weak var typeOfItem: NSPopUpButton!
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var predicateScrollView: NSScrollView!
    @IBOutlet weak var predicateView: NSPredicateEditor!
    
   @IBAction func showPredicateEditor(_ sender: NSPopUpButton) {
    if sender.selectedTag() == Selection.smartList.rawValue {
            bottomView.isHidden=false
            resizePredicateScrollView(predicateView)
        }else {
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
        if typeOfItem.selectedTag()==Selection.smartList.rawValue {//isSmartList.state==NSButton.StateValue.on {
            resizePredicateScrollView(sender)
        }
    }
    
    //Creates the new list item.
    @IBAction func createList(_ sender: NSButton) {
        //Configure new list.
        let nameOfList = nameTextField.stringValue
        switch typeOfItem.selectedTag() {
        case Selection.smartList.rawValue:
            _=QuoteList.init(inMOC: moc, andName: nameOfList, withSmartList: predicateView.predicate)
        case Selection.tag.rawValue:
            _=QuoteList.init(inMOC: moc, andName: nameOfList)
        case Selection.list.rawValue:
            _ = QuoteList.init(inMOC: moc, andName: nameOfList)
        case Selection.folder.rawValue:
            print("To implement")
        default:
            self.dismiss(self) //TODO: Show Error message
        }
        
        try! moc.save() //save
        self.dismiss(self)
    }
}



