//
//  ImporterController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/28/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class ImporterController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func importSelectedFile(_ sender: Any){
        let pathString = Bundle.main.path(forResource: "JSONTODELETE", ofType: ".json")
        let path2 = URL(fileURLWithPath: pathString!)
        //let filePath = URL(fileURLWithPath: "/Users/Gonche/Desktop/exportedOnFeb24.txt")
        
        let jsonString = """
    {
    "quoteString": "empor tempor commodo sit nisi",
    "isFavorite": 1,
    "from": {"name": "Juan Harmon"},
    "isAbout": {"themeName":"commodo"},
    }
"""
 
        let jsonData2 = jsonString.data(using: .utf8)!
        let jsonData = (try! String(contentsOf: path2)).data(using:.utf8)!
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedContext!]=moc
        
        try! decoder.decode([Quote].self, from: jsonData)
        try! moc.save()
        
        //Get keys??
        /*
        var results = [String:[AnyObject]]()
        let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers);
        for (key, value) in jsonResult {
            print("key \(key) value2 \(value)")
        }
 */
        
    }
    
}
