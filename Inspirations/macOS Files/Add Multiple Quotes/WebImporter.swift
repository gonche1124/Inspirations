//
//  WebImporter.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 2/7/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Cocoa
import SwiftSoup

class WebImporter: NSViewController {

    //Web pages available.
    enum selectedWP:String {
        case wikipedia = "wikiQuote"
        case BrainyQuote = "brainyQuote"
        case wordOfWisdom = "InspirationalWordsOfWisdom"
        case eduro = "eduroQuote"
    }
    
    ///Enum for dictionary.
    private enum coreKey:String{
        case author, quote, theme, tags
    }
    
    //Outlets.
    weak var embeddedController:AddQuoteController?
    @IBOutlet weak var progressIndicator:NSProgressIndicator?
    @IBOutlet weak var notificationLabel:NSTextField?
    @IBOutlet weak  var embeddedView:NSView?
    
    //MARK: Overwrite
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide views while it loads.
        self.progressIndicator?.isHidden=true
        self.notificationLabel?.isHidden=true
        self.embeddedView?.isHidden=true
    }
    
    //Called after viewDidLoad for embedded controller.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let dest = segue.destinationController as? AddQuoteController{
            self.embeddedController=dest
            embeddedController?.viewType = .downloading
        }
    }
    
    //MARK: - Cusotm methods.
    ///Picks the right parser and adds it to the embedded container.
    public func selectParser(for webpage:selectedWP){
        var parsedQuote: Dictionary<coreKey,String>?
        
        //Downlaod the quote.
        switch webpage {
        case .BrainyQuote:
            parsedQuote = self.downloadFromBrainyQuote()
        case .eduro:
           parsedQuote = self.downloadFromEduro()
        case .wikipedia:
            parsedQuote = self.downloadFromWikipedia()
        case .wordOfWisdom:
            parsedQuote = self.downloadFromWordOfWisdom()
        }
        //Check for quote and fill
        //TODO: Make this function throw error to display in the notification to the user.
        guard let newQuote = parsedQuote else {
            fatalError("Unable to donwload the quote.")
        }
        //Execute given a new quote.
        self.embeddedView?.isHidden=false
        self.progressIndicator?.stopAnimation(self)
        self.progressIndicator?.isHidden = true
        self.notificationLabel?.stringValue = "Succesfully downloaded the quote."
        fillEmbeddedContainer(with: newQuote)
        self.notificationLabel?.isHidden = true
    }
    
    ///Fills the values from the dictionary into the single embedde container to let the user modify the values.
    private func fillEmbeddedContainer(with newQuote:Dictionary<coreKey,String>){
        self.embeddedController?.quoteTextField.stringValue=newQuote[.quote] ?? "Unable to download quote"
        self.embeddedController?.authorComboBox.stringValue=newQuote[.author] ?? "Unable to donwload author name"
        if let tag = newQuote[.tags] {
            self.embeddedController?.tokenField.objectValue=[Tag.foc(named: tag, in: moc)]
        }
    }
    
    //MARK: - Web parsers.
    /// Extracts Quote from BrainyQuote and return a dictionary with the values.
    private func downloadFromBrainyQuote()->Dictionary<coreKey,String>?{
        //Create html document.
        let stringURL = "https://www.brainyquote.com/quote_of_the_day"
        guard let brainyURL = URL.init(string: stringURL),
            let htmlString = try? String.init(contentsOf: brainyURL),
            let html = try? SwiftSoup.parse(htmlString) else {return nil}
        
        
        //Get author name and quote string.
        let author = try? html.select("a.oncl_q > img").attr("alt").split(separator: "-")[1]
        let quote = try? html.select("a.oncl_q > img").attr("alt").split(separator: "-")[0]
        
        //Create Dictionary:
        var dictionaryOUT = Dictionary<coreKey,String>()
        dictionaryOUT[.quote]=String(quote ?? "")
        dictionaryOUT[.author]=String(author ?? "")
        dictionaryOUT[.tags]="BrainyQuote"
        return dictionaryOUT
    }
    
    /// Extracts quote from Eduro and returns a dictionary with the info.
    private func downloadFromEduro()->Dictionary<coreKey,String>?{
        //Create html document.
        let stringURL = "https://www.eduro.com"
        guard let eduroURL = URL.init(string: stringURL),
            let htmlString = try? String.init(contentsOf: eduroURL),
            let html = try? SwiftSoup.parse(htmlString) else {return nil}
        
        //Get author name and quote string.
        let quote = try? html.select("dailyquote p").array()[0].text().trimWhites()
        let author = try? html.select("dailyquote p").array()[1].text().replacingOccurrences(of: "–", with: "").trimWhites()
        
        //Create Dictionary:
        var dictionaryOUT = Dictionary<coreKey,String>()
        dictionaryOUT[.quote]=String(quote ?? "")
        dictionaryOUT[.author]=String(author ?? "")
        dictionaryOUT[.tags]="Eduro"
        return dictionaryOUT
    }
    
    /// Extracts quote from wikipedia
    private func downloadFromWikipedia()->Dictionary<coreKey,String>?{
        //Create html document.
        let stringURL = "https://en.wikiquote.org/wiki/Main_Page"
        guard let wikipediaURL = URL.init(string: stringURL),
            let htmlString = try? String.init(contentsOf: wikipediaURL),
            let html = try? SwiftSoup.parse(htmlString) else {return nil}
        
        //Get author name and quote.
        let quote = try? html.select("#mf-qotd div table tbody tr td table tbody tr td table tbody tr td").array().first?.text()
        let author = try? html.select("#mf-qotd div table tbody tr td table tbody tr td table tbody tr td").array().last?.select("a").text()
        
        //Create Dictionary:
        var dictionaryOUT = Dictionary<coreKey,String>()
        dictionaryOUT[.quote]=String((quote ?? "") )
        dictionaryOUT[.author]=String((author ?? "") )
        dictionaryOUT[.tags]="Wikipedia"
        return dictionaryOUT
    }
    
    // Extracts quote from wordOfWisdom
    private func downloadFromWordOfWisdom()->Dictionary<coreKey,String>?{
        return nil
        let xx="https://www.wow4u.com/quote-of-the-day/"
        //html body.ezCSS div#wrapper.ezCSS div#page.ezCSS div#content.ezCSS div#ezoic-content.ezCSS div.ezoic-wrapper.ezoic-main-content.ezoic-wrapper-content.ezCSS div#stylesheet_body div table.ez_wrap_table tbody tr td font
    }
    
}

//MARK: - NSMenuDelegate
extension WebImporter:NSMenuDelegate{
    ///Used to call the parser based on the selection.
    func menuDidClose(_ menu: NSMenu) {
        //Performs checks.
        guard let agcMenu = menu.highlightedItem as? AGC_NSMenuItem,
            let identifier=agcMenu.identifier,
            let selectedWebPage = selectedWP(rawValue: identifier.rawValue) else {
                fatalError("No method for selected type")
        }
        
        //Inform the user and download.
        self.notificationLabel?.isHidden=false
        self.progressIndicator?.isHidden=false
        self.progressIndicator?.isIndeterminate=true
        self.progressIndicator?.startAnimation(self)
        self.notificationLabel?.stringValue = "Downloading quote..."
        self.embeddedView?.isHidden=true
        DispatchQueue.main.async {
            self.selectParser(for: selectedWebPage)
        }
    }
}
