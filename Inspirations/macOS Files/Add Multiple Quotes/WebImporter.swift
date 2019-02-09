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
    
    //Outlets.
    weak var embeddedController:AddQuoteController?
    @IBOutlet weak var progressIndicator:NSProgressIndicator?
    @IBOutlet weak var notificationLabel:NSTextField?
    @IBOutlet weak  var embeddedView:NSView?
    
    //MARK: Overwrite
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViwDIDLOAD")
        
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
        self.embeddedView?.isHidden=false
        switch webpage {
        case .BrainyQuote:
            if let newQuote = self.downloadFromBrainyQuote(){
                fillEmbeddedContainer(with: newQuote)
            }
        case .eduro:
            if let newQuote = self.downloadFromEduro(){
                fillEmbeddedContainer(with: newQuote)
            }
        case .wikipedia:
            if let newQuote = self.downloadFromWikipedia(){
                fillEmbeddedContainer(with: newQuote)
            }
        case .wordOfWisdom:
            if let newQuote = self.downloadFromWordOfWisdom(){
                fillEmbeddedContainer(with: newQuote)
            }
        }
    }
    
    ///Fills the values from the dictionary into the single embedde container to let the user modify the values.
    public func fillEmbeddedContainer(with newQuote:Dictionary<String,String>){
        print(newQuote)
        self.embeddedController?.quoteTextField.stringValue=newQuote["quoteString"] ?? "Unable to download quote"
        self.embeddedController?.authorComboBox.stringValue=newQuote["name"] ?? "Unable to donwload author name"
    }
    
    //MARK: - Web parsers.
    //Extracts Quote from BrainyQuote and return a dictionary with the values.
    func downloadFromBrainyQuote()->Dictionary<String,String>?{
        //Create html document.
        let stringURL = "https://www.brainyquote.com/quote_of_the_day"
        guard let brainyURL = URL.init(string: stringURL),
            let htmlString = try? String.init(contentsOf: brainyURL),
            let html = try? SwiftSoup.parse(htmlString) else {return nil}
        
        
        //Get author name and quote string.
        let author = try? html.select("a.oncl_q > img").attr("alt").split(separator: "-")[1]
        let quote = try? html.select("a.oncl_q > img").attr("alt").split(separator: "-")[0]
        
        //Create Dictionary:
        var dictionaryOUT = Dictionary<String,String>()
        dictionaryOUT["quoteString"]=String(quote ?? "")
        dictionaryOUT["name"]=String(author ?? "")
        dictionaryOUT["tags"]="BrainyQuote"
        return dictionaryOUT
    }
    
    //Extracts quote from Eduro and returns a dictionary with the info.
    func downloadFromEduro()->Dictionary<String,String>?{
        //Create html document.
        let stringURL = "https://www.eduro.com"
        guard let eduroURL = URL.init(string: stringURL),
            let htmlString = try? String.init(contentsOf: eduroURL),
            let html = try? SwiftSoup.parse(htmlString) else {return nil}
        
        //Get author name and quote string.
        let quote = try? html.select("dailyquote p").array()[0].text().trimWhites()
        let author = try? html.select("dailyquote p").array()[1].text().replacingOccurrences(of: "–", with: "").trimWhites()
        
        //Create Dictionary:
        var dictionaryOUT = Dictionary<String,String>()
        dictionaryOUT["quoteString"]=String(quote ?? "")
        dictionaryOUT["name"]=String(author ?? "")
        dictionaryOUT["tags"]="Eduro"
        return dictionaryOUT
    }
    
    // Extracts quote from wikipedia
    func downloadFromWikipedia()->Dictionary<String,String>?{
        //Create html document.
        let stringURL = "https://en.wikiquote.org/wiki/Main_Page"
        guard let wikipediaURL = URL.init(string: stringURL),
            let htmlString = try? String.init(contentsOf: wikipediaURL),
            let html = try? SwiftSoup.parse(htmlString) else {return nil}
        
        //Get author name and quote.
        let quote = try? html.select("#mf-qotd div table tbody tr td table tbody tr td table tbody tr td").array().first?.text()
        let author = try? html.select("#mf-qotd div table tbody tr td table tbody tr td table tbody tr td").array().last?.select("a").text()
        
        //Create Dictionary:
        var dictionaryOUT = Dictionary<String,String>()
        dictionaryOUT["quoteString"]=String((quote ?? "") ?? "")
        dictionaryOUT["name"]=String((author ?? "") ?? "")
        dictionaryOUT["tags"]="Wikipedia"
        return dictionaryOUT
    }
    
    // Extracts quote from wordOfWisdom
    func downloadFromWordOfWisdom()->Dictionary<String,String>?{
        return nil
        let xx="https://www.wow4u.com/quote-of-the-day/"
        //html body.ezCSS div#wrapper.ezCSS div#page.ezCSS div#content.ezCSS div#ezoic-content.ezCSS div.ezoic-wrapper.ezoic-main-content.ezoic-wrapper-content.ezCSS div#stylesheet_body div table.ez_wrap_table tbody tr td font
    }
    
}

//MARK: - NSMenuDelegate
extension WebImporter:NSMenuDelegate{
    func menuDidClose(_ menu: NSMenu) {
        
        guard let agcMenu = menu.highlightedItem as? AGC_NSMenuItem,
            let identifier=agcMenu.identifier,
            let selectedWebPage = selectedWP(rawValue: identifier.rawValue) else {
                fatalError("No method for selected type")
        }
        
        self.notificationLabel?.isHidden=false
        self.progressIndicator?.isHidden=false
        self.progressIndicator?.isIndeterminate=true
        self.progressIndicator?.startAnimation(nil)
        self.notificationLabel?.stringValue = "Downloading quote"
        
        selectParser(for: selectedWebPage)
    }
}
