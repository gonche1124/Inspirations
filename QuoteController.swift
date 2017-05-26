//
//  QuoteController.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 5/26/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa


//class quoteCell: NSTableCellView {
//    
//    @IBOutlet weak var labelQuote: NSTextField!
//    @IBOutlet weak var labelAuthor: NSTextField!
//    
//    
//}

//Controller Class
class QuoteController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        
        
    }
    
    //Variables
    dynamic lazy var moc = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    //IBOutlets
    @IBOutlet var quotesArray: NSArrayController!
    @IBOutlet weak var quotesTable: NSTableView!
    
}

// MARK: Extensions
extension QuoteController: NSTableViewDelegate {
    
    //Calculate the size of the rows
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
 
        //Get the size of the table
        let tableWidth = tableView.tableColumns.first?.width
        
        //Get the text size
        let quoteText: NSString = ((self.quotesArray.arrangedObjects as! NSArray).object(at: row) as! Quote).quote! as NSString
        let textCalculation: CGSize = quoteText.size(withAttributes: [NSFontAttributeName: NSFont.init(name: "Helvetica", size: 18.0)!])
        let finalSize = textCalculation.width/tableWidth!
        
        return 85+ceil(27*(finalSize-0.5))
    }
    
    //Recalculate when the screen moves
    func tableViewColumnDidResize(_ notification: Notification) {
        let allIndex = IndexSet(integersIn:0..<self.quotesTable.numberOfRows)
        quotesTable.noteHeightOfRows(withIndexesChanged: allIndex)
    }
    
}

