//
//  BigViewController.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 3/29/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Cocoa

class BigViewController: NSViewController {

    //Outlets
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var textFieldQuote: NSTextField!
    @IBOutlet weak var textFieldAuthor: NSTextField!
    @IBOutlet weak var positionalSlider: NSSlider!
    @IBOutlet weak var topicPill: NSButton!
    @IBOutlet weak var favImage: NSImageView!
    
    //Variables
    var tabVC:AGCTabContentController{return parent as! AGCTabContentController}
    var currentQuote:Quote? {
        didSet{
            textFieldQuote.stringValue = currentQuote?.quoteString ?? "No selection"
            textFieldAuthor.stringValue = currentQuote?.from?.name ?? "No selection"
            topicPill.title = currentQuote?.isAbout?.themeName ?? "No selection"
            favImage.image = NSImage.init(imageLiteralResourceName: (currentQuote!.isFavorite ? "red heart" : "grey heart"))
        }
    }
    
    //MARK: - Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        //Updates with latest quote.
        let quoteArray = tabVC.quoteFRC.fetchedObjects
        let newQuote = quoteArray?[(tabVC.lastSelectedRows.last ?? 0)]
        self.currentQuote = newQuote
        
        //Sets up the slider:
        positionalSlider.maxValue = Double(quoteArray!.count)
        positionalSlider.minValue = 0
        positionalSlider.altIncrementValue = 1
        positionalSlider.integerValue = tabVC.lastSelectedRows.last ?? 0
        
    }
    
    /// Updates the buttons and the slider basedon the new FRC values and selection.
    func updateViewFromFRC(){
        self.previousButton.isEnabled = !(tabVC.lastSelectedRows.last == 0)
        self.nextButton.isEnabled = !(tabVC.quoteFRC.fetchedObjects?.count == tabVC.lastSelectedRows.last)
        self.positionalSlider.maxValue = Double(tabVC.quoteFRC.fetchedObjects?.count ?? 0)
    }
    
    
    //MARK: - Actions.
    @IBAction func showPrevious(_ sender: NSButton) {
        print(#function)
        self.currentQuote = tabVC.quoteFRC.fetchedObjects?[tabVC.lastSelectedRows.lastIndex(offset: -1)]
        updateViewFromFRC()
    }
    
    @IBAction func showNext(_ sender: NSButton) {
        print(#function)
        let newQuote = tabVC.quoteFRC.fetchedObjects?[tabVC.lastSelectedRows.lastIndex(offset: 1)]
        self.currentQuote = newQuote
        updateViewFromFRC()
    }
    
    @IBAction func showQuoteX(_ sender: NSSlider) {
        print(sender.intValue)
        let offset = sender.integerValue - (tabVC.lastSelectedRows.last ?? 0)
        let newQuote = tabVC.quoteFRC.fetchedObjects?[tabVC.lastSelectedRows.lastIndex(offset:offset)]
        self.currentQuote = newQuote
        updateViewFromFRC()
        
    }
}
