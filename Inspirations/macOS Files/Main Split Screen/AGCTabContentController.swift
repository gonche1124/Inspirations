//
//  AGCTabContentController.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 3/29/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Cocoa

class AGCTabContentController: NSTabViewController {
    
    lazy var quoteFRC:NSFetchedResultsController<Quote> = {
        let fr=NSFetchRequest<Quote>(entityName: Entities.quote.rawValue)
        fr.sortDescriptors = [NSSortDescriptor(keyPath: \Quote.quoteString, ascending: true)]
        let frc=NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        //frc.delegate=self
        try! frc.performFetch()
        return frc
        //TODO: Check before loading if there are any filters active or a different item selectedd.
    }()
    
    var searchF:AGCSearchField? {return principalWC?.mainSearchField}
    var principalWC: PrincipalWindow? {return NSApp.mainWindow?.windowController as? PrincipalWindow}
    var lastSelectedRows:IndexSet = IndexSet.init(integer: 0)
    var leftItem:LibraryItem!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Local variables
        self.leftItem = pContainer.viewContext.get(standardItem: .mainLibrary)
        
        //Set up for notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(leftSelectionChanged(notification:)), name: .leftSelectionChanged, object: nil)

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        searchF?.target = self
        searchF?.action = #selector(updateContents(_:))
        //Configure SegmentedView.
        principalWC?.segmentedButtons.target = self
        principalWC?.segmentedButtons.action = #selector(segmentChange(_:))
    }
    
    //MARK: - Actions
    @objc func segmentChange(_ sender: NSSegmentedControl) {
        self.selectedTabViewItemIndex = sender.selectedSegment
        //(NSApp.delegate as? AppDelegate)?.exportSelectedmenu.isEnabled = !(sender.indexOfSelectedItem == 2)
        //(NSApp.delegate as? AppDelegate)?.exportSelectedmenu.isHidden = (sender.indexOfSelectedItem == 2)
    }
    
    /// Updates the Controller with the parameters.
    /// - parameter withPredicate: NSPredicate that is used to update the FRC.
    /// - parameter andSortDescriptor: Array of sort descriptors to use
    func updateController(withPredicate newPredicate: NSPredicate,
                          andSortDescriptors: [NSSortDescriptor]?=[NSSortDescriptor(keyPath: \Quote.quoteString, ascending: true)]){
        
        quoteFRC.fetchRequest.predicate = newPredicate
        quoteFRC.fetchRequest.sortDescriptors=andSortDescriptors
        try? quoteFRC.performFetch()
        let selectedVC = tabViewItems[selectedTabViewItemIndex].viewController
        if let selectedVC = selectedVC as? MultipleColumnsController {
            selectedVC.table.reloadData()
        }
        if let selectedVC = selectedVC as? SingleColumnController{
            selectedVC.table.reloadData()
        }
        if let selectedVC = selectedVC as? BigViewController {
            lastSelectedRows = IndexSet(arrayLiteral: 0)
            selectedVC.currentQuote = quoteFRC.fetchedObjects?[lastSelectedRows.first!]
            selectedVC.updateViewFromFRC()
        }
    }
    
    /// Called when the user changes the left selection.
    @objc func leftSelectionChanged(notification: Notification){
        if let selectedLib = notification.object as? LibraryItem {
            self.leftItem=selectedLib
            self.updateController(withPredicate: selectedLib.quotePredicate)
        }
    }
    
    /// Called when the user enters text in the NSSearchfield.
    @IBAction func updateContents(_ sender: NSSearchField){
        if sender.stringValue.count > 0 {
            let orPred = NSCompoundPredicate(ORcompundWithText: sender.stringValue)
            let andPred = NSCompoundPredicate(andPredicateWithSubpredicates: [orPred, leftItem.quotePredicate])
            updateController(withPredicate: andPred)
        }else{
            updateController(withPredicate: leftItem.quotePredicate)
        }
    }
}
//MARK: - 
extension AGCTabContentController: NSTableViewDataSource{
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return quoteFRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return quoteFRC.fetchedObjects?[row]
    }
    
    /// Used for sorting of columns.
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {return}
        updateController(withPredicate: quoteFRC.fetchRequest.predicate!,
                         andSortDescriptors:[sortDescriptor])
    }
    
    //Copy-Pasting
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let thisQuote = quoteFRC.object(at: IndexPath(item: row, section: 0))
        let thisItem = NSPasteboardItem()
        thisItem.setString(thisQuote.getID(), forType: .string)
        return thisItem
    }
}



