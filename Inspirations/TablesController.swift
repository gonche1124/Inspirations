//
//  TablesController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/19/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


import Cocoa

class TablesController: NSViewController {
    
    //Variables
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
                
                //All
                sField.bind(NSBindingName.predicate, to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"All",NSBindingOption.predicateFormat:pAll])
                
                //Author
                sField.bind(NSBindingName(rawValue: "predicate2"), to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"Author",NSBindingOption.predicateFormat:pAuthor])
                
                //Theme
                sField.bind(NSBindingName(rawValue: "predicate3"), to: quoteController, withKeyPath: "filterPredicate", options: [NSBindingOption.displayName:"Theme",NSBindingOption.predicateFormat:pTheme])
            }
        }
    
    
    
    }
    
    //Intercept keystrokes
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
        //fn makes this flow happen.
        let modFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if modFlags.contains(.command) {
            switch event.characters{
            case "i":
                print("Nothing")
                //self.performSegue(withIdentifier:.init("editSegue"), sender: self)
            case "f":
                self.updateFavoriteValue(newValue:!modFlags.contains(.shift))
            default:
                break
            }
        }
    }
    
    //Update favorite attribute
    func updateFavoriteValue(newValue:Bool){
        self.quoteController.selectedObjects.forEach({($0 as! Quote).isFavorite=newValue})
        try! self.moc.save()
    }
    
    //Action to set favorite attribute
    @IBAction func setFavoriteAttribute(_ sender: Any?){
        guard let menuItem = sender as? NSMenuItem else {return}
        if menuItem.tag==1 {
            self.updateFavoriteValue(newValue: true)
        }else if menuItem.tag==2{
            self.updateFavoriteValue(newValue: false)
        }
    }
    
    //Add the tag or
    @IBAction func addTagsOrPlaylists(_ sender: NSMenuItem?){
        if let urlRep=URL(string: ((sender?.identifier?.rawValue)!)),
            let objectId=moc.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: urlRep),
            let coreItem=try? moc.existingObject(with: objectId){
            if let tag=coreItem as? Tag {
                tag.addToHasQuotes(NSSet(array: self.quoteController.selectedObjects))
            }else if let playlist=coreItem as? QuoteList{
                playlist.addToHasQuotes(NSSet(array: self.quoteController.selectedObjects))
            }
            try! self.moc.save()
        }
    }
    
    //Delete selected Records.
    override func deleteBackward(_ sender: Any?) {
        let confirmationD = NSAlert()
        confirmationD.messageText = "Delete Records"
        confirmationD.informativeText = "Are you sure you want to delete the \(table?.numberOfSelectedRows ?? 0) selected Quotes?"
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
                self.selectedLeftItem=selectedLib
                self.quoteController.fetchPredicate=newPredicate
                self.quoteController.fetch(nil)
        }
    }
}



//MARK: - NSTableViewDataSource
extension TablesController: NSTableViewDataSource{
    
    //Copy Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
       //let test =
        let thisQuote = (quoteController.arrangedObjects as! [Quote])[row]
        let thisItem = NSPasteboardItem()
        //thisItem.setString(thisQuote, forType: .string)
        thisItem.setString(thisQuote.objectID.uriRepresentation().absoluteString, forType: .string)
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
    
    //Called before being shown
    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu.identifier?.rawValue=="tagMenu"{
            menu.removeAllItems()
            try! Tag.allInContext(moc).forEach({
                menu.addMenuItem(title: $0.name!,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        }else if menu.identifier?.rawValue=="listMenu"{
            menu.removeAllItems()
            try! QuoteList.allInContext(moc).forEach({
                menu.addMenuItem(title: $0.name!,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
          })
        }
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



