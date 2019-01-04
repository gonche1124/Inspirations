//
//  Smar List Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa


//TODO: Change size to ask first what type of item you want ot add through combobox and remove checkbox.
class SmartListController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        predicateView.addRow(nil)
        predicateScrollView.isHidden=true
        //bottomView.isHidden=true
        
        //Reconfigure view if it was called as an edit window.
        if (selectedObject != nil){
            self.nameTextField.stringValue=(selectedObject?.name)!
            self.createButton.title="Update"
            self.createButton.action=#selector(updateItemName(_:))
            self.typeOfItem.isHidden=true
            if let listO=selectedObject as? QuoteList, let predc=listO.smartPredicate {
                predicateScrollView.isHidden=false
                self.predicateView.objectValue=predc
            }
        }
    }
    
    //Used to change the appeareance of the screen.
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.appearance=NSAppearance(named: .vibrantDark)
    }
    
    //Properties
    //@IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var heightScrollViewPredicate: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var typeOfItem: NSPopUpButton!
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var predicateScrollView: NSScrollView!
    @IBOutlet weak var predicateView: NSPredicateEditor!
    
    @IBOutlet weak var predciateHeight: NSLayoutConstraint!
    weak var leftVC: LeftController?
    
    //Properties set from parent view Controller
    var selectedObject:LibraryItem?
    
    //Used for bindings.
    @objc dynamic var nameProxy:String?
    
    //MARK: - Class methods
    /// TODO: FInish this method.
    @IBAction func closeCurrentWindow(_ sender:NSButton){
        self.dismiss(self)
    }
    
   @IBAction func popUpButtonChanged(_ sender: NSPopUpButton) {
    if sender.selectedTag() == Selection.smartList.rawValue {
            predicateScrollView.isHidden=false
            //bottomView.isHidden=false
            //resizePredicateScrollView(predicateView)
        }else {
            predicateScrollView.isHidden=true
            //bottomView.isHidden=true
        }
    }
    
    /// Called anytime there is action on the predicate.
    @IBAction func predicatedChanged(_ sender: NSPredicateEditor) {
        if typeOfItem.selectedTag()==Selection.smartList.rawValue {//isSmartList.state==NSButton.StateValue.on {
            let newRowCount = sender.numberOfRows
            let rowHeight = sender.rowHeight
            predciateHeight.animator().constant=CGFloat(newRowCount)*rowHeight
        }
    }
    
    /// Enabled and called only when theuser wants to create a new item with the name of the textfield.
    @IBAction func createList(_ sender: NSButton) {
        //Configure new list.
        let nameOfList = nameTextField.stringValue
        if let selectedType = Selection(rawValue: typeOfItem.selectedTag()){
            switch selectedType{
            case .smartList:
                _ = QuoteList.init(inMOC: moc, andName: nameOfList, withSmartList: predicateView.predicate)
            case .tag:
                _=Tag.init(inMOC: moc, andName: nameOfList)
            case .list:
                _ = QuoteList.init(inMOC: moc, andName: nameOfList)
            case .folder:
                if let leftListView = leftVC?.listView,
                    let selectedObject = leftListView.item(atRow: leftListView.selectedRow) as? LibraryItem{
                    _ = LibraryItem.init(inMoc: moc, folderNamed: nameOfList, underItem: selectedObject)
                    print("To implement")
                }
        }
        self.saveMainContext()
        self.dismiss(self)
        }
    }
    
    ///Updates list name (and predicate if neccesary) for the selected Item.
    /// - Note: this gets assigned in ViewDidLoad depending on the caller.
    @IBAction func updateItemName(_ sender:NSButton){
        if !nameTextField.stringValue.trimmingCharacters(in: .whitespaces).isEmpty{
            self.selectedObject?.name=nameTextField.stringValue
            self.saveMainContext()
            self.dismiss(self)
        }else{
            let alert = NSAlert()
            alert.messageText = "Empty Name"
            alert.informativeText = "Name can not be empty"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .warning
            alert.runModal()
        }
        
    }
}



