//
//  AppDelegate.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 3/23/17.
//  Copyright © 2017 Gonche. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    //Window Delegate methods
    func windowDidResize(_ notification: Notification) {
        //print("Resized")
    }
    
     func applicationWillFinishLaunching(_ notification: Notification) {
        
        //Register for NSManagedObject Notifications
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self.managedObjectContext)
        
        //createObjectsIfTheyDontExist()
        //createRandomQuotes()
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print(self.applicationDocumentsDirectory.path)
        

        //Sets color of main Window
        //NSApp.mainWindow?.backgroundColor=NSColor(calibratedWhite: 0.99, alpha: 1)
        //NSApp.mainWindow?.backgroundColor=NSColor.white
        
        //TO Erase after is working.
//        let fetchR = NSFetchRequest<Tags>(entityName: "Tags")
//        let tagsArray = try! self.managedObjectContext.fetch(fetchR)
//        tagsArray.forEach({
//
//
//            if ($0.isInTag?.tagName) != nil {
//                  print ("Not to Delete:")
//            }
//            else {
//                if $0.isLeaf {
//                    print ("To Delete:")
//                    self.managedObjectContext.delete($0)
//                }
//                else {
//                print ("Not To Delete:")
//                }
//            }
//            print("\($0.tagName), isLeaf=\($0.isLeaf) inside \($0.isInTag?.tagName)")
//
//        })
//        try! self.managedObjectContext.save()
//        print("Finished")
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("com.apple.toolsQA.CocoaApp_CD")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Core Data ERD", withExtension: "momd")!
        //let modelURL = Bundle.main.url(forResource: "Inspirations", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try self.applicationDocumentsDirectory.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !properties.isDirectory! {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("Inspirations.storedata")
            do {
                let optionsMigration = [ NSInferMappingModelAutomaticallyOption : true,
                                NSMigratePersistentStoresAutomaticallyOption : true] //Added for migration purposes.
                try coordinator!.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: url, options: optionsMigration)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                 
                /*
                 Typical reasons for an error here include:
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            if let error = failError {
                NSApplication.shared.presentError(error)
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
            fatalError("Unsresolved error: \(failureReason)")
        } else {
            return coordinator!
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy=NSMergePolicy.mergeByPropertyStoreTrump //Custom Line of code to avoid duplicates.
        return managedObjectContext
    }()
    

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSApplication.ModalResponse.alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    //MARK: - Core Data Notifications
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let moc=self.managedObjectContext
        if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {

            
            //Update Favorites playlist.
//            if let qList = updated.filter({$0.className=="Quote" && $0.changedValuesForCurrentEvent()["isFavorite"] != nil}) as? Set<Quote>,let favTag=Tags.firstWith(predicate: NSPredicate(format: "tagName == %@", "Favorites"), inContext: moc) as? Tags {
//
//                _=qList.filter({$0.isFavorite==true}).map({$0.addToHasTags(favTag)})
//                _=qList.filter({$0.isFavorite==false}).map({$0.removeFromHasTags(favTag)})
            }
            
       // }
        
//        if let inserted=userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count>0, let qList = inserted.filter({$0.className=="Quote"}) as? Set<Quote> {
//
//            //Using extensions to add default "Main" playlist. Should move this to account if user deletes playlist by error?.
//            if let mainTag=Tags.firstWith(predicate: NSPredicate(format: "tagName == %@", "Quotes"), inContext: moc) as? Tags{
//                _=qList.map({$0.addToHasTags(mainTag)})
//            }
//        }
    }
    
    //TODO
    func createObjectsIfTheyDontExist() {
        
        //Create root items.
        let libRoot = create(object: "LibraryItem", withAttributes: ["isRootItem":true, "isShown":true, "name":"Library"]) as! LibraryItem
        let tagRoot=create(object: "LibraryItem", withAttributes:["isRootItem":true, "isShown":true, "name":"Tags"]) as! LibraryItem
        let lanRoot=create(object: "LibraryItem", withAttributes:["isRootItem":true, "isShown":true, "name":"Languages"]) as! LibraryItem
        let collRoot=create(object: "LibraryItem", withAttributes:["isRootItem":true, "isShown":true, "name":"Lists"]) as! LibraryItem
        
        //Only for testing:
        for item in ["Library", "Favorites"]{
            let coreItem=create(object: "LibraryItem", withAttributes: ["isRootItem":false, "isShown":true, "name":item]) as! LibraryItem
            coreItem.belongsToLibraryItem=libRoot
        }
        for tag in ["Love", "Inspirational", "Wow", "Brainer", "Cerebral"]{
            let coreItem=create(object: "Tag", withAttributes: ["isRootItem":false, "isShown":true, "name":tag]) as! Tag
            coreItem.belongsToLibraryItem=tagRoot
        }
        for language in ["Spanish", "English", "French", "German", "Mandarin"]{
            let coreItem=create(object: "Language", withAttributes: ["isRootItem":false, "isShown":true, "name":language]) as! Language
            coreItem.belongsToLibraryItem=lanRoot
        }
        for lista in ["Top 25", "For Work", "From Movies", "In songs", "Crazy"]{
            let coreItem=create(object: "QuoteList", withAttributes: ["isRootItem":false, "isShown":true, "name":lista]) as! QuoteList
            coreItem.belongsToLibraryItem=collRoot
        }
        
        
        try! self.managedObjectContext.save()
    }
    
    //TODO
    func create(object: String, withAttributes:Dictionary<String, Any>)->NSManagedObject{
        let coreEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: object, into: self.managedObjectContext)
        coreEntity.setValuesForKeys(withAttributes)
        return coreEntity
    }
    
    //For Testing only
    func createRandomQuotes(){
        let quoteA: [String]=["Love is in the Air"
            ,"Reach for the moon, even if  you miss you will land among the starts"
            , "What a wonderful world it was"
            , "Wierd is just a point of view"
            , "Random is life"
            , "Travel lightly"]
        let authorA=["John", "Mike", "Andres", "Felipe", "Geoff"]
        let themeN = ["Love", "Faith", "Courage"]
        let isF = [true, false]
        for _ in 1...20{
            
            //TODO: create NSMANAgedObject(context:moc) convinience init.
            let thisQuote = NSEntityDescription.insertNewObject(forEntityName: "Quote", into: managedObjectContext) as? Quote//Quote(context: managedObjectContext)
            thisQuote?.quoteString = quoteA[Int(arc4random_uniform(UInt32(quoteA.count)))]
            let currAuthor = NSEntityDescription.insertNewObject(forEntityName: "Author", into: managedObjectContext) as? Author//Author(context: managedObjectContext)
            currAuthor?.name = authorA[Int(arc4random_uniform(UInt32(authorA.count)))]
            thisQuote?.from=currAuthor
            thisQuote?.isFavorite=isF[Int(arc4random_uniform(UInt32(isF.count)))]
            let currTheme = NSEntityDescription.insertNewObject(forEntityName: "Theme", into: managedObjectContext) as? Theme//Theme(context: managedObjectContext)
            currTheme?.themeName = themeN[Int(arc4random_uniform(UInt32(themeN.count)))]
            thisQuote?.isAbout=currTheme
        }
        try! self.managedObjectContext.save()
    }

}


