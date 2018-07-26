//
//  AlternateController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 7/25/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Cocoa

class AlternateController: NSViewController {

    //TO ERASE FTER CORE DATA
    lazy var testArrayNum = [Array(0...4), Array(2...5), Array(7...10)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

//NSOutlineViewDataSource Extension.
extension AlternateController: NSOutlineViewDataSource {
    
    //Has to be efficient, gets called multiple times. (nil means root).
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        print("Methd called with")
        
        if item == nil {
            return testArrayNum.count
        }
        else if let tot = (item as? Array<Int>)?.count {
            return tot
        }
        else {
            return 0
        }
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? Array<Any> else {return false}
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return testArrayNum[index]
        }
        else{
            return (item as? Array<Any>)![index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return testArrayNum
    }
    
    //Required for editing.
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
        
    }
}

//Mark: NSOutlineViewDelegate
extension AlternateController: NSOutlineViewDelegate{
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var myCell: NSTableCellView?
        if let item=item as? Array<Any> {
            myCell = (outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "HeaderCell"), owner: self) as? NSTableCellView)!
            myCell?.textField?.stringValue=String(item.count)
            print(String(item.count))
        }
        else if let item=item as?Int {
            myCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "DataCell"), owner: self) as? NSTableCellView
            myCell?.textField?.stringValue=String(item)
            print(String(item))
        }
        return myCell
    }
    
}

