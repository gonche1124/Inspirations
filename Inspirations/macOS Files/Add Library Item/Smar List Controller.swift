//
//  Smar List Controller.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa


class SmartListController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        predicateView.addRow(nil)
        self.predicateScrollView.isHidden=true
        
        
        //Reconfigure view if it was called as an edit window.
        if (selectedObject != nil){
            self.nameTextField.stringValue=(selectedObject?.name)!
            self.createButton.title="Update"
            self.createButton.action=#selector(updateItemName(_:))
            
            if let listO=selectedObject as? QuoteList, let predc=listO.smartPredicate {
                self.predicateScrollView.isHidden=false
                self.predicateView.objectValue=predc
            }
        }else if hasPredicate {
            self.predicateScrollView.isHidden=false
        }
        
        
        
    }
    
    //Properties
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var predicateScrollView: NSScrollView!
    @IBOutlet weak var predicateView: NSPredicateEditor!
    
    //Properties set from parent view Controller
    weak var leftVC: LeftController?
    var selectedObject:LibraryItem?
    var itemType: LibraryType?
    var hasPredicate: Bool = false
    
    //Used for bindings to enable nsbutton.
    @objc dynamic var nameProxy:String?
    
    //MARK: - Class methods
    /// TODO: FInish this method.
    @IBAction func closeCurrentWindow(_ sender:NSButton){
        self.dismiss(self)
    }
    
    
    /// Called anytime there is action on the predicate.
//    @IBAction func predicatedChanged(_ sender: NSPredicateEditor) {
//        if typeOfItem.selectedTag()==Selection.smartList.rawValue {//isSmartList.state==NSButton.StateValue.on {
//            let newRowCount = sender.numberOfRows
//            let rowHeight = sender.rowHeight
//            predciateHeight.animator().constant=CGFloat(newRowCount)*rowHeight
//        }
//    }
    
    /// Enabled and called only when theuser wants to create a new item with the name of the textfield.
    @IBAction func createList(_ sender: NSButton) {
        //Configure new list.
        let nameOfList = nameTextField.stringValue
//        if let selectedType = Selection(rawValue: typeOfItem.selectedTag()){
//            switch selectedType{
//            case .smartList:
//                _ = QuoteList.init(inMOC: moc, andName: nameOfList, withSmartList: predicateView.predicate)
//            case .tag:
//                _=Tag.init(inMOC: moc, andName: nameOfList)
//            case .list:
//                _ = QuoteList.init(inMOC: moc, andName: nameOfList)
//            case .folder:
//                if let leftListView = leftVC?.listView,
//                    let selectedObject = leftListView.item(atRow: leftListView.selectedRow) as? LibraryItem{
//                    _ = LibraryItem.init(inMoc: moc, folderNamed: nameOfList, underItem: selectedObject)
//                    print("To implement")
//                }
//        }
        self.saveMainContext()
        self.dismiss(self)
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



