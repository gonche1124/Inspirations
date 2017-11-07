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
        self.view.layer?.backgroundColor=NSColor.init(red: 163, green: 212, blue: 255, alpha: 0.5).cgColor
    }
}



//View Controller
class CollectionController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

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
