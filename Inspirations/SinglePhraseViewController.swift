//
//  SinglePhraseViewController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 4/12/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

class SinglePhraseViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Populate the NSFetched Controller
        do{
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        //Populate the stats text field
        updateStatistic(itemN: 1)
        
        
    }
    
    //MARK: Updates Screen
    //Updates screen
    func updateStatistic(itemN: Int){
        totalStatistic.stringValue = "Item \(itemN) of \(String(describing: fetchedResultsController.fetchedObjects?.count))"
    }
    
    func updateAuthor(author: String){
        authorField.stringValue=author
    }
    
    func updateQuote(quote: String){
        
        
        //let currFrame = quoteLabel.frame
        quoteLabel.stringValue = quote
        let stringHeight: CGFloat = quoteLabel.attributedStringValue.size().height
        
        let frame = quoteLabel.frame
        var titleRect:  NSRect = quoteLabel.cell!.titleRect(forBounds: frame)
        
        titleRect.size.height = stringHeight + ( stringHeight - (quoteLabel.font!.ascender + quoteLabel.font!.descender ) )
        titleRect.origin.y = frame.size.height / 2  - quoteLabel.lastBaselineOffsetFromBottom - quoteLabel.font!.xHeight / 2
        quoteLabel.frame = titleRect
        
        
    }
    
    
    //MARK: Variables
    var currItem = 0
    fileprivate lazy var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    fileprivate lazy var quotesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quote")
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController <NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Quote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fromAuthor.firstName", ascending: false)]
        let moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        //frc.delegate = self
        return frc
        
    }()
    
    @IBAction func previousQuote(_ sender: Any) {
        
        if currItem-1 >= 1 {
            currItem-=1
            let currQuote = fetchedResultsController.object(at: NSIndexPath(forItem: currItem, inSection: 0) as IndexPath) as! Quote
            updateQuote(quote: currQuote.quote!)
            //updateAuthor(author: (currQuote.fromAuthor?.firstName)!)
            updateStatistic(itemN: currItem)
        }
        
    }
    
    @IBAction func nextQuote(_ sender: Any) {
        if currItem+1 <= (fetchedResultsController.fetchedObjects?.count)! {
            currItem+=1
            let currQuote = fetchedResultsController.object(at: NSIndexPath(forItem: currItem, inSection: 0) as IndexPath) as! Quote
            updateQuote(quote: currQuote.quote!)
            //updateAuthor(author: (currQuote.fromAuthor?.firstName)!)
            updateStatistic(itemN: currItem)
        }
    }
    
    //MARK: Outlets
    @IBOutlet weak var totalStatistic: NSTextField!
    @IBOutlet weak var quoteLabel: NSTextField!
    @IBOutlet weak var authorField: NSTextField!
    
}
