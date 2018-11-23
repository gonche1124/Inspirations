//
//  MultipleImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 11/22/18.
//  Copyright © 2018 Gonche. All rights reserved.
//


import Cocoa
import WebKit
import SwiftSoup

//Mark: - Parent Import Controller.
class MainImportController:NSViewController{
    
    var myFormat:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        return formatter
    }()
    
    //Outlets.
    @IBOutlet weak var importQuotes:NSButton!
    @IBOutlet weak var progressIndicator:NSProgressIndicator!
    @IBOutlet weak var progressLabel:NSTextField!
    
    //Sets the progress idnicator and labels as enabled, not hidden and animated.
    func showProgress(withLabel:String?=nil, andStarting:Bool=true){
        self.progressIndicator.isHidden=false
        self.progressLabel.isHidden=false
        self.progressIndicator.usesThreadedAnimation=true
        
        if andStarting{
            progressIndicator.startAnimation(nil)
        }
        if let newLabel=withLabel{
            progressLabel.stringValue=newLabel
        }
    }
    
    //Turns indefinite progress to definite
    func convertIndicatorTodefinate(withItems:Double, andLabel:String?=nil){
        progressIndicator.stopAnimation(nil)
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue=1
        progressIndicator.maxValue=withItems
    }
    
    //used to override the UI parameters.
    override func viewWillAppear() {
        super.viewWillAppear()
        self.progressIndicator.isHidden=true
        self.progressLabel.isHidden=true
    }
    
    //Save and close
    @IBAction func saveAndClose(_ sender:Any){
        try! moc.save()
        self.view.window?.close()
    }
    
}
//MARK: -
class FileImporter: MainImportController {
    
    //private variables
    fileprivate var fileURL:URL?
    
    //Outlets
    @IBOutlet weak var pathField:NSTextField!
    
    //Gets the filepath and saves it to the NSTextfield
    @IBAction func chooseFile(_ sender:NSButton){
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a .json file";
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt", "json"];
        if (dialog.runModal() == NSApplication.ModalResponse.OK), let result = dialog.url {
            pathField.stringValue=result.path
            fileURL = result
        }
    }
    
    @IBAction func importQuotesFromJSON(_ sender:NSButton){
        
        //Create the dictionary to Parse.
        guard let dictArrayDirty=getDictionary(fromURL: fileURL!) else {return}
        
        //Set up Prvate MOC for importing and not blocking interface.
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        //Set up UI
        showProgress(withLabel: "Loading quotes...", andStarting: true)
        
        //Clean dictionary with right keys:
        //TODO: Check for possible keys before passing.
        progressLabel.stringValue="Cleaninig quotes..."
        let lookUP=["quote":"quoteString", "topic":"themeName"]
        let dictArray=dictArrayDirty.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
        let totItems=dictArrayDirty.count
        self.convertIndicatorTodefinate(withItems: Double(totItems))
        
        //Import
        privateMOC.perform{
            //Create Quotes updating the UI
            for (i, quoteDict) in dictArray.enumerated(){
                _=Quote.firstOrCreate(inContext: privateMOC, withAttributes: quoteDict, andKeys: ["quoteString"])
                DispatchQueue.main.async {
                    self.progressLabel.stringValue="Importing \(self.myFormat.string(for: i+1)!) quote out of \(self.myFormat.string(for:totItems)!)"
                    self.progressIndicator.increment(by: 1)
                }
            }
            
            //Save private moc:
            DispatchQueue.main.async {
                self.progressLabel.stringValue="Saving \(self.myFormat.string(for:totItems)!) quotes..."
                self.progressIndicator.isIndeterminate=true
                self.progressIndicator.startAnimation(nil)
            }
            try! privateMOC.save()
            
            //Save main moc:
            DispatchQueue.main.async {try! self.moc.save()}
            
            //Dismiss
            DispatchQueue.main.async {self.dismiss(nil)}
        }
    }
    
    //Converts the URL into a dictionary to be able to parse.
    func getDictionary(fromURL:URL)->[[String:Any]]?{
        guard let testData = try? Data.init(contentsOf: fromURL) else{
            print("Could not create data from JSON file")
            return nil
        }
        guard let tempDictArray = try? JSONSerialization.jsonObject(with: testData, options: []) else{
            print("Could not create  JSON Object.")
            return nil
        }
        guard let dictArrayDirty = tempDictArray as? [[String:Any]] else{
            print("could not create dicitonary from JSON Object.")
            return nil
        }
        return dictArrayDirty
    }
    
    //Recursively cleans a Dictionary
    func cleanUp(dictionary inDict:[String:Any], mappingTo lookUP:[String:String])->[String:Any]{
        
        var outDictionary=[String:Any]()
        for (key, value) in inDict{
            //value is a dictionary.
            if let valueDict=value as? [String:Any]{
                let newValue=cleanUp(dictionary: valueDict, mappingTo: lookUP)
                outDictionary[lookUP[key] ?? key]=newValue
            }else if let valueArr=value as? [[String:Any]]{
                let newValue=valueArr.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
                outDictionary[lookUP[key] ?? key]=newValue
            }
            else{
                outDictionary[lookUP[key] ?? key]=value
            }
        }
        return outDictionary
    }
}
//MARK: -
class WebImporter: MainImportController {
    
    //Web pages available.
    enum selectedWP:String {
        case wikipedia = "wikiQuote"
        case forbes = "forbesQuote"
        case BrainyQuote = "brainyQuote"
        case wordOfWisdom = "InspirationalWordsOfWisdom"
        case enduro = "enduroQuote"
    }
    
    //Outlets
    @IBOutlet weak var webDisplay:WKWebView!
    @IBOutlet weak var webPopUpButton:NSPopUpButton!
    
    //Used to load the initial web page.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedMenu = webPopUpButton.selectedItem as? AGC_NSMenuItem, let selectedURL=URL.init(string:selectedMenu.customURLString){
            webDisplay.load(URLRequest(url:selectedURL))
        }
    }
    
    //Import Quote of the day.
    @IBAction func importQuoteFromWeb(_ sender:NSButton){
        
        //Make sure it can pull the link
        guard let selMenuItem = webPopUpButton?.menu?.highlightedItem as? AGC_NSMenuItem,
            let selIdentifier = selMenuItem.identifier?.rawValue,
            let rawIdentifier = selectedWP(rawValue: selIdentifier) else {
                print("Could not create identifier")
                return
        }
        
        showProgress(withLabel: "Parsing Html code...", andStarting: true)
        processWebPage(forWebPage: rawIdentifier)
    }
    
    //process the webpage and calls switch statement.
    func processWebPage(forWebPage webPage:selectedWP){
        webDisplay.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: {(response:Any?, error:Error?) in
            
            guard let htmlString = response as? String else {
                //TODO: Restore UI and infrom user.
                return
            }
            guard let myHTML=try? SwiftSoup.parse(htmlString) else {
                return
            }
            self.extractQuotefromHTML(forWebPage: webPage, andHTML: myHTML)
            
        })
    }
    
    //Extracts the quote.
    func extractQuotefromHTML(forWebPage:selectedWP, andHTML:Document){
        progressLabel.stringValue="Parsing quote..."
        switch forWebPage {
        case .forbes:
            if let newQuote=importQuoteFrom(forbes:andHTML){
                self.saveAndClose("nil")
            }
        case .wikipedia:
            if let newQuote=importQuoteFrom(wikipedia:andHTML){
                self.saveAndClose("nil")
            }
        case .BrainyQuote:
            if let newQuote=importQuoteFrom(brainyQuote: andHTML){
                self.saveAndClose("nil")
            }
        default:
            print("To Implement")
        }
    }
    
    //Extracts the data from Wikipedia and ads the quote.
    func importQuoteFrom(wikipedia:Document)->Quote?{
        
        //Get Array of info.
        guard let quoteArray=try? wikipedia.select("#mf-qotd div table tbody tr td table tbody tr td table tbody tr td").array(), quoteArray.count==2, let quoteString = try! quoteArray.first?.text(), let name=try! quoteArray.last?.select("a").text() else {
            return nil
        }
        
        //Create quote
        let quoteDict:[String : Any] = ["quoteString":quoteString, "fromAuthor":["name":name], "isAbout":["themeName":"Wikipedia"]]
        if let newQuote = Quote.firstOrCreate(inContext:moc, withAttributes:quoteDict, andKeys:["quoteString"]) as? Quote{
            return newQuote
        }
        return nil
    }
    
    //extracts the data from Forbes quote of the day.
    func importQuoteFrom(forbes:Document)->Quote?{
        //TODO: Finish implementing. Add tag to indicate donwlaoded from Web.
        guard let quoteString = try? forbes.select("p.p.p2.ng-binding").text() else {
            return nil
        }
        let name = try? forbes.select("cite.ng-binding")//.array().first
        let quoteDict:[String : Any] = ["quoteString":quoteString, "fromAuthor":["name":name], "isAbout":["themeName":"Forbes"]]
        if let newQuote = Quote.firstOrCreate(inContext:moc, withAttributes:quoteDict, andKeys:["quoteString"]) as? Quote{
            return newQuote
        }
        return nil
    }
    
    //Extracts Quote from BrainyQuote
    func importQuoteFrom(brainyQuote brainy:Document)->Quote?{
        guard let allString = try? brainy.select("a.oncl_q").first()?.getElementsByTag("img").attr("alt"),
        let stringArray=allString?.components(separatedBy: CharacterSet.init(charactersIn: "-")),
            stringArray.count==2 else {
            return nil
        }
        
        let name = stringArray.last!.trimmingCharacters(in: .whitespaces)
        let quoteString = stringArray.first!.trimmingCharacters(in: .whitespaces)
        let quoteDict:[String : Any] = ["quoteString":quoteString, "fromAuthor":["name":name], "isAbout":["themeName":"Brainy Quote"]]
        if let newQuote = Quote.firstOrCreate(inContext:moc, withAttributes:quoteDict, andKeys:["quoteString"]) as? Quote{
            return newQuote
        }
        return nil
    }
    
}

//MARk: - NSMenuDelegate
extension WebImporter:NSMenuDelegate{
    func menuDidClose(_ menu: NSMenu) {
        guard let agcMenu = menu.highlightedItem as? AGC_NSMenuItem else {return}
        guard let selectedURL=URL.init(string: agcMenu.customURLString) else {return}
        webDisplay.load(URLRequest.init(url: selectedURL))
    }
}





//MARK: - NSTabViewController
class TabViewImportController:NSTabViewController{
    
    //private lazy var tabViewSizes: [String : NSSize] = [:]
    
    //View did Load.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Used to center the toolbarItems.
    override func viewWillAppear() {
        super.viewWillAppear()
        if let toolBar = view.window?.toolbar {
            toolBar.insertItem(withItemIdentifier: .flexibleSpace, at: 0)
            toolBar.insertItem(withItemIdentifier: .flexibleSpace, at: 3)
        }
    }
    
    //    override func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewController.TransitionOptions = [], completionHandler completion: (() -> Void)? = nil) {
    //        NSAnimationContext.runAnimationGroup({ context in
    //            context.duration = 1//0.5
    //            self.updateWindowFrameAnimated(viewController: toViewController)
    //            super.transition(from: fromViewController, to: toViewController, options: [.crossfade, .allowUserInteraction], completionHandler: completion)
    //        }, completionHandler: nil)
    //    }
    //
    //    func updateWindowFrameAnimated(viewController: NSViewController) {
    //
    //        guard let title = viewController.title, let window = view.window else {
    //            return
    //        }
    //
    //        let contentSize: NSSize
    //
    //        if tabViewSizes.keys.contains(title) {
    //            contentSize = tabViewSizes[title]!
    //        }
    //        else {
    //            contentSize = viewController.view.frame.size
    //            tabViewSizes[title] = contentSize
    //        }
    //
    //        let newWindowSize = window.frameRect(forContentRect: NSRect(origin: NSPoint.zero, size: contentSize)).size
    //
    //        var frame = window.frame
    //        frame.origin.y += frame.height
    //        frame.origin.y -= newWindowSize.height
    //        frame.size = newWindowSize
    //        window.animator().setFrame(frame, display: false)
    //    }
    
    
}

