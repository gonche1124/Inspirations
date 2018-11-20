//
//  ImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa
import WebKit
import SwiftSoup

class ImporterController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        // Do view setup here.
        let webPage = URL.init(string:"https://en.wikiquote.org/wiki/Main_Page")
        webDisplay?.load(URLRequest(url: webPage!))
        self.fieldName.isHidden=true
        self.importProgressIndicator.isHidden=true
    }
    
    
    //Properties
    var jsonURL: URL?
    @IBOutlet weak var pathToFile: NSTextField?
    @IBOutlet weak var importProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var fieldName: NSTextField!
    @IBOutlet weak var webDisplay: WKWebView?
    @IBOutlet weak var webPopUpButton:NSPopUpButton?
    @IBOutlet weak var importTabView:NSTabView!

    
    //MARK: - Actions
    //Chooses a file.
    @IBAction func chooseFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a .json file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt", "json"];
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                pathToFile?.stringValue=result.path
                self.jsonURL = result
            }
        }
    }
    
    //Import button pressed. Decides which type of importation should perform.
    @IBAction func importButtonPressed(_ sender:Any){
        guard let selectedItem=importTabView.selectedTabViewItem?.identifier as? String else {return}
        switch selectedItem {
        case "jsonTabItem":
            print("JSON")
        case "webTabItem":
            print("WEB")
        default:
            print("error")
        }
    }
    
    //Decodes selected file.
    @IBAction func importSelectedFile(_ sender: Any){
        
        //self.jsonURL = URL(fileURLWithPath: pathToFile.stringValue)
        if (pathToFile?.stringValue.count)! > 0{
            
            //create private moc to avoid potential thread errors.
            let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            //privateMOC.mergePolicy=NSMergePolicy.mergeByPropertyObjectTrump
            privateMOC.parent = moc
            
            //Set up the UI for importing
            self.importProgressIndicator.isHidden=false
            self.importProgressIndicator.usesThreadedAnimation=true
            self.importProgressIndicator.startAnimation(nil)
            self.fieldName.isHidden=false
            self.fieldName.stringValue="Loading quotes..."
            
            //Create JSON array object.
            guard let testData = try? Data.init(contentsOf: jsonURL!) else {return} //TODO: print proper information.
            guard let tempDictArray = try? JSONSerialization.jsonObject(with: testData, options: []) else {return}
            guard let dictArrayDirty = tempDictArray as? [[String:Any]] else {return}
            
            //Clean dictionary with right keys:
            //TODO: Check for possible keys before passing.
            self.fieldName.stringValue="Cleaninig quotes..."
            let lookUP=["quote":"quoteString", "topic":"themeName"]
            let dictArray=dictArrayDirty.map({cleanUp(dictionary: $0, mappingTo: lookUP)})
            
            
            //UI
            let totItems=Double(dictArray.count)
            self.importProgressIndicator.stopAnimation(nil)
            self.importProgressIndicator.isIndeterminate=false
            self.importProgressIndicator.minValue=1
            self.importProgressIndicator.maxValue=totItems
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            
            //Import
            print(privateMOC.automaticallyMergesChangesFromParent)
            privateMOC.perform{
                for (i, quoteDict) in dictArray.enumerated(){
                    //Create Entity
                    _=Quote.firstOrCreate(inContext: privateMOC, withAttributes: quoteDict, andKeys: ["quoteString"])
                    //Update UI:
                    DispatchQueue.main.async {
                        self.fieldName.stringValue="Importing \(formatter.string(for: i+1)!) quote out of \(formatter.string(for:totItems)!)"
                        self.importProgressIndicator.increment(by: 1)
                    }
                }
                
                //Save private moc:
                DispatchQueue.main.async {
                    self.fieldName.stringValue="Saving \(formatter.string(for:totItems)!) quotes..."
                    self.importProgressIndicator.isIndeterminate=true
                    self.importProgressIndicator.startAnimation(nil)
                }
                try! privateMOC.save()
                
                //Save main moc:
                DispatchQueue.main.async {try! self.moc.save()}
                
                //Dismiss
                DispatchQueue.main.async {self.dismiss(nil)}
            }
        }
    }
    
    //Import from web page
    @IBAction func importFromWebPage(_ sender:NSButton){
        print("Importing from web page")
        //let webPage = URL.init(string:"https://en.wikiquote.org/wiki/Main_Page")
        guard let selectedItem=webPopUpButton?.menu?.highlightedItem as? AGC_NSMenuItem else{return}
        let webPage = URL.init(string: selectedItem.customURLString)
        switch selectedItem.identifier?.rawValue {
        case "forbesQuote":
            //TODO: Figure out how to handle the JAVASCRIPT CODE.
            if let newQuote=importQuote(fromForbes: webPage!){
                print(newQuote)
            }
        case "wikiQuote":
            if let newQute=importQuote(fromWikiQuote: webPage!){
                print(newQute)
            }
        default:
            print("To Implement")
        }

        print(" eee")
    }
    
    //Parses web page to returns quote fo the day.
    //TODO: Refactor code.
    func importQuote(fromForbes urlToParse:URL)->[String:String]?{
        print(#function)
        //Get html form javascript code.
        let test1 = "document.documentElement.outerHTML.toString()"
        let myDict = webDisplay?.evaluateJavaScript(test1, completionHandler: {(rightHTML:Any?, error:Error?) in
            
            let doc: Document = try! SwiftSoup.parse(rightHTML as! String)
            let quote = try? doc.select("p.p.p2.ng-binding").text()
            let author = try? doc.select("cite.ng-binding")//.array().first
            print(author)
            
        })
     
        
        
        //Make sure it can load and parse the data into SwiftSoup element.
        let myReq=URLRequest(url: urlToParse)
        var response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        let data = try? NSURLConnection.sendSynchronousRequest(myReq, returning: response)
        let myHTML = String(data: data!, encoding: .ascii)
        
    
        guard let html=try? String.init(contentsOf:urlToParse, encoding:.utf8), let doc: Document = try? SwiftSoup.parse(html) else {
            print("Could not load and parse web page")
            return nil
        }
        
        return nil
    }
    
    //Parses the web page and extracts the quote of the day.
    func importQuote(fromWikiQuote urlToParse:URL)->[String:String]? {
        
        //Make sure it can load and parse the data into SwiftSoup element.
        guard let html=try? String.init(contentsOf:urlToParse, encoding:.utf8), let doc: Document = try? SwiftSoup.parse(html) else {
            print("Could not load and parse web page")
            return nil
        }
        //Make sure it can find and separate the quote of the day node.
        guard let firstNode = try? doc.select("#mf-qotd tbody tr").first(),let elementArray = try? firstNode!.text().components(separatedBy: CharacterSet.init(charactersIn: "~")) else{
            print("Could not find the div and separate the node.")
            return nil
        }
        
        //Decompose the array into dictoinary.
        //TODO: figure out how to handle utf8 encodings.
        if elementArray.count>1,
            let quoteString=String(utf8String: elementArray[0].cString(using: .utf8)!),
            let name=String(utf8String: elementArray[1].cString(using: .utf8)!){
            return ["quoteString":quoteString, "name":name]
        }
        return nil
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

//Delegate for the POPUP button
extension ImporterController: NSMenuDelegate{
    func menuDidClose(_ menu: NSMenu) {
        //Update WebView
        guard let agcMenu=menu.highlightedItem as? AGC_NSMenuItem else {return}
        let selectedURL=URL.init(string:agcMenu.customURLString)
        webDisplay?.load(URLRequest.init(url: selectedURL!))
        print("Menu closed with selection: \(menu.highlightedItem?.title)")
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
