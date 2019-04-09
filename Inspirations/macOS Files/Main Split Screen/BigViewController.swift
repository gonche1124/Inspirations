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
        if let quoteArray=tabVC.quoteFRC.fetchedObjects{
            self.currentQuote = quoteArray[tabVC.lastSelectedRows.last!]
            updateViewFromFRC()
        }
    }
    
    /// Updates the buttons and the slider basedon the new FRC values and selection.
    func updateViewFromFRC(){
        self.previousButton.isEnabled = !(tabVC.lastSelectedRows.last == 0)
        self.nextButton.isEnabled = !(tabVC.quoteFRC.fetchedObjects?.count == (tabVC.lastSelectedRows.last!+1))
        
        self.positionalSlider.minValue = 1
        self.positionalSlider.maxValue = Double(tabVC.quoteFRC.fetchedObjects!.count)
        self.positionalSlider.integerValue = tabVC.lastSelectedRows.last! + 1
        
        let newtext = "Quote \(positionalSlider.integerValue) of \(tabVC.quoteFRC.fetchedObjects?.count ?? 0)"
        NotificationCenter.default.post(Notification(name: .updateDisplayText, object: newtext, userInfo: nil))
    }
    
    
    //MARK: - Actions.
    /// Shows the previous quote in the FRC.
    @IBAction func showPrevious(_ sender: NSButton) {
        currentQuote = tabVC.quoteFRC.fetchedObjects?[tabVC.lastSelectedRows.lastIndex(offset: -1)]
        updateViewFromFRC()
    }
    
    /// Shows the next quote in the FRC.
    @IBAction func showNext(_ sender: NSButton) {
        let newQuote = tabVC.quoteFRC.fetchedObjects?[tabVC.lastSelectedRows.lastIndex(offset: 1)]
        self.currentQuote = newQuote
        updateViewFromFRC()
    }
    
    /// Called when the sliders moves.
    @IBAction func showQuoteX(_ sender: NSSlider) {
        let offset = sender.integerValue - (tabVC.lastSelectedRows.last!+1)
        let newQuote = tabVC.quoteFRC.fetchedObjects?[tabVC.lastSelectedRows.lastIndex(offset:offset)]
        self.currentQuote = newQuote
        updateViewFromFRC()
        
    }
}
