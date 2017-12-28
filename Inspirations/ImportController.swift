//
//  ImportController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 12/21/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

protocol progressMade: ProgressReporting {
    
}

class ImportController: NSViewController {

    
    //Outlets.
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusProgress: NSProgressIndicator!
    @IBOutlet weak var importButton: NSButton!
    @IBOutlet weak var pathTextField: NSTextField!
    
    var urlToImport:URL?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func chooseFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a JSON file"
        dialog.showsResizeIndicator = true
        dialog.allowedFileTypes = ["json", "txt"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            self.urlToImport=dialog.url!
            self.pathTextField.stringValue=dialog.url!.absoluteString
            self.importButton.isEnabled=true
        }
    }
    
    @IBAction func importQuotes(_ sender: NSButton) {
        let importJson = importExport()
        let arrayOfQuotes = importJson.parseJSONFile(pathToFile: self.urlToImport!)
        importJson.progressInstance!.addObserver(self, forKeyPath: "fractionCompleted", options: [], context: nil)
        importJson.progressInstance!.addObserver(self, forKeyPath: "completedUnitCount", options: [], context: nil)
        self.statusLabel.isHidden=false
        self.statusProgress.isHidden=false
        importJson.importFromJSONV2(array:arrayOfQuotes)
    }
    
    //MARK: - Key-Value Oberving
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let progressMade = object as? Progress{
            if keyPath == "completedUnitCount" {
                if progressMade.completedUnitCount>=progressMade.totalUnitCount {
                    self.statusLabel.stringValue = "Finished"
                    self.dismiss(nil)
                }
            }
            if keyPath == "fractionCompleted" {
                DispatchQueue.main.async {
                    self.statusProgress.doubleValue=progressMade.fractionCompleted
                    self.statusLabel.stringValue = progressMade.localizedAdditionalDescription
                }
                
            }
        }
        
    }
    
    
}
