//
//  CollectionController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/7/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

//Item Controller
class CollectionQuoteItem: NSCollectionViewItem {

    @IBOutlet var authorLabel : NSTextField?
    @IBOutlet var quoteLabel : NSTextField?
    @IBOutlet var favoriteImage: NSImageView?
    
    var quoteEntity : Quote? {
        didSet {
            guard isViewLoaded else {return}
            if let quoteEntity = quoteEntity {
                quoteLabel?.stringValue = quoteEntity.quote!
                quoteLabel?.toolTip = quoteEntity.quote!
                authorLabel?.stringValue = (quoteEntity.fromAuthor?.name!)!
                (quoteEntity.isFavorite) ? nil : (favoriteImage?.isHidden=true)
            }
        }
    }
    //Func did load.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer=true
        self.view.layer?.cornerRadius=10
        self.view.layer?.borderWidth = 2
        self.view.layer?.borderColor = NSColor.blue.cgColor
        //self.view.layer?.backgroundColor=NSColor.red.cgColor
    }
}


//View Controller
class CollectionController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        currentCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    @objc dynamic lazy var moc = (NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var currentCollectionView: NSCollectionView!
    @IBOutlet var quotesController: NSArrayController!
}


extension CollectionController: NSCollectionViewDataSource {
    
    //Total umber of items in each section.
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return (quotesController.arrangedObjects as! NSArray).count
    }
    
    //Return item
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let currItem = collectionView.makeItem(withIdentifier:NSUserInterfaceItemIdentifier(rawValue:"CollectionQuoteItem"), for: indexPath)
        guard let currView = currItem as? CollectionQuoteItem else {return currItem}
        currView.quoteEntity = (self.quotesController.arrangedObjects as! NSArray)[indexPath.item] as? Quote

        return currView
        
    }
}

extension CollectionController: NSCollectionViewDelegateFlowLayout{
    //Calculate the size for each item depending of the
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let viewW = collectionView.frame.width - 30
        if viewW < 300 {return NSSize(width: viewW, height: viewW/2.1)}
        else if (viewW >= 300) && (viewW < 600) {return NSSize(width: viewW/2, height: viewW/2/2.1)}
        else {return NSSize(width: viewW/3, height: viewW/3/2.1)}
    }
}

//MARK: NSSearchFieldDelegate
extension CollectionController: NSSearchFieldDelegate{
    
    //Gts called when user ends searhing
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.quotesController.filterPredicate = nil
        self.currentCollectionView.reloadData()
        (self.parent as? ViewController)?.updateInfoLabel(parameter: "All")
    }
    
    //Gets called when user searches
    override func controlTextDidChange(_ obj: Notification) {
        let tempSearch = (obj.object as? NSSearchField)!.stringValue
        if tempSearch != "" {
            self.quotesController.filterPredicate = NSPredicate(format: "fromAuthor.name CONTAINS[cd] %@", tempSearch)
            self.currentCollectionView.reloadData()
            (self.parent as? ViewController)?.updateInfoLabel(parameter: (self.quotesController.arrangedObjects as! NSArray).count)
        }
    }
    
}
