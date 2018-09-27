//
//  TablesController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/19/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


//TODO: Display right click menu to show delete, favorites, add to list, etc
import Cocoa

class TablesController: NSViewController {
    
    //Variables
    //let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
    var deletesFromDatabase=false  //TODO: Implement
    var selectedLeftItem:LibraryItem? {
        didSet{
            let newBool = (selectedLeftItem?.libraryType == LibraryType.tag.rawValue || selectedLeftItem?.libraryType == LibraryType.list.rawValue)
            self.deletesFromDatabase=newBool
        }
    }
    
    
    @IBOutlet var quoteController: NSArrayController!
    @IBOutlet weak var table: NSTableView?
    @IBOutlet var rightMenu: NSMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Setup Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(leftTableChangedSelection(notification:)), name: .leftSelectionChanged, object: nil)
        
    }
    
    //USed to set as delegate the 
    override func viewDidAppear() {
        if let searchToolbarItem = view.window?.toolbar?.items.first(where: {$0.itemIdentifier.rawValue == "mainSearchField"}){
            if let sField = searchToolbarItem.view as? NSSearchField {
                //sField.delegate=self
                let bindingsDic:[NSBindingOption:Any] = [NSBindingOption.displayName:"predicateGonche",                 NSBindingOption.predicateFormat:pAll]
                
                
                sField.bind(NSBindingName.predicate, to: quoteController, withKeyPath: "filterPredicate", options: bindingsDic)
                
                sField.bind(NSBindingName(rawValue: "predicate2"), to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"Author",                 NSBindingOption.predicateFormat:pAuthor])
 
            }
        }
    
    
    
    }
    
    //Intercept keystrokes
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    //Action upadte favorites.
    @IBAction func setFavorite(_ sender: Any){

        let newValue = (menu?.identifier!.rawValue == "favorite")
//        self.tableFRC.selectedObjects?.forEach({$0.isFavorite=newValue})
        try! self.moc.save()
        
    }
    
    //Delete selected Records.
    override func deleteBackward(_ sender: Any?) {
        let confirmationD = NSAlert()
        confirmationD.messageText = "Delete Records"
        confirmationD.informativeText = "Are you sure you want to delete the \(table?.numberOfSelectedRows) selected Quotes?"
        confirmationD.addButton(withTitle: "Ok")
        confirmationD.addButton(withTitle: "Cancel")
        confirmationD.alertStyle = .warning
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            self.table?.beginUpdates()
            //self.tableFRC.selectedObjects?.forEach({moc.delete($0)})
            self.table?.endUpdates()
        }
        do{
            try self.moc.save()
        }catch{
            print(error)
        }
    }
    
    //Left selection changed
    @objc func leftTableChangedSelection(notification: Notification){
        if let selectedLib = notification.object as? LibraryItem,
            let newPredicate = NSPredicate.predicateFor(libraryItem: selectedLib){
            //TODO: IMPLEMENT FOR ARRAY CONTROLLER
                self.selectedLeftItem=selectedLib
                //self.updatesController(withPredicate: newPredicate)
        }
    }
}



//MARK: - NSTableViewDataSource
extension TablesController: NSTableViewDataSource{
    
    //Copy Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let thisQuote = "dd"//tableFRC.fetchedObjects?[row]
        let thisItem = NSPasteboardItem()
        //thisItem.setString((thisQuote?.objectID.uriRepresentation().absoluteString)!, forType: .string)
        return thisItem
    }
    

}

//MARK: - TableViewDelegate
extension TablesController: NSTableViewDelegate{
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            NotificationCenter.default.post(Notification(name: .selectedRowsChaged, object: myTable, userInfo: nil))
        }
    }

}

//MARK: - NSMenuDelegate
extension TablesController: NSMenuDelegate{
    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu.identifier?.rawValue=="tagMenu"{
            ["One", "Two", "Three"].forEach({menu.addItem(withTitle: $0, action: nil, keyEquivalent: "")})
        }else if menu.identifier?.rawValue=="listMenu"{
            ["One", "Two", "Three"].forEach({menu.addItem(withTitle: $0, action: nil, keyEquivalent: "")})
        }
       
            
            //menu.item(withTag: 2)?.submenu?.addItem(menuItem)
            
        }
    
}

//TODO: Move into independent file


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



