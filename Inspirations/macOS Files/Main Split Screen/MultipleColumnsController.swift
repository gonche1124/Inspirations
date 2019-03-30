//
//  MultipleColumnsController.swift
//  Inspirations-macOS
//
//  Created by Andres Gonzalez Casabianca on 3/29/19.
//  Copyright © 2019 Gonche. All rights reserved.
//

import Cocoa

class MultipleColumnsController: NSViewController {

    //Outlets.
    @IBOutlet weak var table: NSTableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        table.dataSource = parent as? NSTableViewDataSource
        table.delegate = self
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        let vc = parent as! AGCTabContentController
        vc.lastSelectedRows = table.selectedRowIndexes
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        table.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let vc = parent as! AGCTabContentController
        table.selectRowIndexes(vc.lastSelectedRows, byExtendingSelection: false)
    }
}

//MARK: - TableViewDelegate
extension MultipleColumnsController: NSTableViewDelegate{
    
    //Changing the selection.
    func tableViewSelectionDidChange(_ notification: Notification) {
        print(#function)
        if let table = notification.object as? NSTableView
        {
            let frc = (parent as! AGCTabContentController).quoteFRC
            let objects = table.selectedRowPaths.map({frc.object(at: $0)}).map({$0.getID()})
            let newtext = "\(table.numberOfSelectedRows) quotes of \(table.numberOfRows)"
            NotificationCenter.default.post(Notification(name: .updateDisplayText, object: newtext, userInfo: nil))
            NotificationCenter.default.post(Notification(name: .rightSelectedRowsChaged, object: objects, userInfo: nil))
        }
    }
}
