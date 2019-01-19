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
    var parentItem:LibraryItem?
    
    //Used for bindings to enable nsbutton.
    @objc dynamic var nameProxy:String?
    
    //MARK: - Class methods
    @IBAction func closeCurrentWindow(_ sender:NSButton){
        self.dismiss(self)
    }
    
    /// Enabled and called only when theuser wants to create a new item with the name of the textfield.
    //TODO: create default values in core data to simplify code and when neccesary overwrite.
    @IBAction func createList(_ sender: NSButton) {
        //Configure new list.
        let nameOfList = nameTextField.stringValue
            switch itemType!{
            case .smartList:
                _ = QuoteList.init(inMOC: moc, andName: nameOfList, withSmartList: predicateView.predicate)
            case .tag:
                _=Tag.init(inMOC: moc, andName: nameOfList)
            case .list:
                _ = QuoteList.init(inMOC: moc, andName: nameOfList)
            case .folder:
                if let leftListView = leftVC?.listView,
                    let selectedObject = leftListView.item(atRow: leftListView.clickedRow) as? LibraryItem{
                    _ = LibraryItem.init(inMoc: moc, folderNamed: nameOfList, underItem: selectedObject)
                    print("To implement")
                }
            default:
                let error2 = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No assigned type"])
                print(error2)
                //TODO: proper handling of errors.
        }
//        }
        self.saveMainContext()
        self.dismiss(self)

        }
    
    
    ///Updates list name (and predicate if neccesary) for the selected Item.
    /// - Note: this gets assigned in ViewDidLoad depending on the caller.
    /// - TODO: If using bindings only need to check not another entity with the same name exists.
    @IBAction func updateItemName(_ sender:NSButton){
        if !nameTextField.stringValue.trimmingCharacters(in: .whitespaces).isEmpty{
            self.selectedObject?.name=nameTextField.stringValue
            self.saveMainContext()
            self.dismiss(self)
        }else{
            let alert = NSAlert()
            alert.messageText = "Empty Name"
            alert.informativeText = "Name can not be empty or same as other item."
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}



