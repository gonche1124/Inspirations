//
//  RightController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/26/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class RightController: NSViewController {
    
    //Outlets:
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var quoteController:NSArrayController!
    @IBOutlet weak var quoteTabView:NSTabView!
    @IBOutlet weak var bottomStackView:NSStackView!
    
    //Variables:
    var deletesFromDatabase=false
    var selectedLeftItem:LibraryItem? {
        didSet{
            //let newBool = [LibraryType.tag.rawValue, LibraryType.list.rawValue].contains(selectedLeftItem?.libraryType)
            self.deletesFromDatabase = ![LibraryType.tag.rawValue, LibraryType.list.rawValue].contains(selectedLeftItem?.libraryType)
        }
    }
    var currentTable:NSTableView?=nil
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedTabView(_:)), name: .selectedViewChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftTableChangedSelection(notification:)), name: .leftSelectionChanged, object: nil)
    }
    
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
    
    //Called before preparing for a segue.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let destinationSegue = segue.destinationController as? AddQuoteController{
            destinationSegue.isInfoWindow=true
            destinationSegue.selectionController!.content=self.quoteController.selectedObjects
            destinationSegue.selectionController!.setSelectedObjects(quoteController.selectedObjects)
        }
    }
    
    //MARK: -
    //Changes the TAB View.
    @IBAction func changeSelectedTabView(_ sender: Any){
        if let segmentedControl = (sender as? NSNotification)?.object as? NSSegmentedControl{
            self.quoteTabView.selectTabViewItem(at: segmentedControl.selectedSegment)
        }
    }
    
    //Left selection changed
    @objc func leftTableChangedSelection(notification: Notification){
        print("Called")
        if let selectedLib = notification.object as? LibraryItem,
            let newPredicate = NSPredicate.predicateFor(libraryItem: selectedLib){
            self.selectedLeftItem=selectedLib
            self.quoteController.fetchPredicate=newPredicate
            self.quoteController.fetch(nil)
        }
    }
    
}

//MARK: - CRUD Core Data:
extension RightController{
    
    ///Updates favorite attribute based on sender parameter.
    @IBAction func modifyFavoriteAttribute(_ sender:Any){
        guard let selectedQuotes=quoteController.selectedObjects as? [Quote] else {return}
        if let menu=sender as? AGC_NSMenuItem {
            selectedQuotes.forEach({$0.isFavorite=menu.agcBool})
        }
        if let boolV=sender as? Bool{
            selectedQuotes.forEach({$0.isFavorite=boolV})
        }
        self.saveMainContext()
    }
    
    
    ///Adds the selected quotes to the tags or playlists specified.
    @IBAction func addTagsOrPlaylists(_ sender: NSMenuItem?){
        if let coreItem=moc.get(objectWithStringID: sender!.identifier!.rawValue){
            if let tag=coreItem as? Tag {
                tag.addToHasQuotes(NSSet(array: self.quoteController.selectedObjects))
            }else if let playlist=coreItem as? QuoteList{
                playlist.addToHasQuotes(NSSet(array: self.quoteController.selectedObjects))
            }
            self.saveMainContext()
        }
    }
    
    //Deletes selected record or records.
    @IBAction func deleteSelectedRecord(_ sender: Any?){
        let confirmationD = NSAlert.init(totalItems: currentTable?.numberOfSelectedRows ?? 0, isDeleting: self.deletesFromDatabase)
        let result = confirmationD.runModal()
        if result == .alertFirstButtonReturn{
            currentTable?.beginUpdates()
            if deletesFromDatabase {
                self.quoteController.selectedObjects.forEach({moc.delete($0 as! NSManagedObject)})
            }else{
                //Case for Tags.
                if let isTag=selectedLeftItem as? Tag {
                    quoteController.selectedObjects.forEach({isTag.removeFromHasQuotes($0 as! Quote)})
                }
                if let isList=selectedLeftItem as? QuoteList{
                    quoteController.selectedObjects.forEach({isList.removeFromHasQuotes($0 as! Quote)})
                }
            }
            currentTable?.endUpdates()
            self.saveMainContext()
        }
    }
}


//MARK: - NSTableViewDataSource
extension RightController: NSTableViewDataSource{
    
    //Copy-Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let thisQuote = (quoteController.arrangedObjects as! [Quote])[row]
        let thisItem = NSPasteboardItem()
        thisItem.setString(thisQuote.getID(), forType: .string)
        return thisItem
    }
}

//MARK: - TableViewDelegate
extension RightController: NSTableViewDelegate{
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let _ = notification.object as? NSTableView,
            let selectedArray = self.quoteController.selectedObjects as? [Quote] {
            NotificationCenter.default.post(Notification(name: .selectedRowsChaged,
                                                         object: selectedArray.map({$0.getID()}),
                                                         userInfo: nil)) //Used for displaying text and for sharing selected Objects
        }
    }
}

//MARK: - NSMenuDelegate
extension RightController: NSMenuDelegate{
    
    //Called before being shown
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        switch menu.identifier?.rawValue {
        //TODO: See if this can be done with bindings.
        case "rightMenu":
            if let deleteItem=menu.item(withIdentifier: "deleteMenuItem"){
                deleteItem.title=self.deletesFromDatabase ? "Delete":"Remove from \(self.selectedLeftItem?.name ?? "")"
            }
        case "tagMenu":
            menu.removeAllItems()
            try! Tag.allInContext(moc).forEach({
                menu.addMenuItem(title: $0.name!,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        case "listMenu":
            menu.removeAllItems()
            try! QuoteList.allInContext(moc).forEach({
                menu.addMenuItem(title: $0.name!,action: #selector(addTagsOrPlaylists(_:)),keyEquivalent: "",identifier: $0.getID())
            })
        default:
            break
        }
    }
}

//MARK: - NSTabViewDelegate
extension RightController:NSTabViewDelegate{
    func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        //TODO: Find a way to get the current table view.
        if let tableView = tabViewItem?.view?.getAllSubViews().firstWith(identifier: "columnTable"), let table=tableView as? NSTableView{
            currentTable=table
            bottomStackView.isHidden=false
            return
        }
        if let tableView = tabViewItem?.view?.getAllSubViews().firstWith(identifier: "exploreTable"), let table=tableView as? NSTableView{
            currentTable=table
            bottomStackView.isHidden=false
            print("Nothing john snow")
            return
        }
        
        currentTable=nil
        bottomStackView.isHidden=true
    }
}
