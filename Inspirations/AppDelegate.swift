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
        //TODO: Uncomment!!!
        //notiCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self.managedObjectContext)

        //Create Main Items.
        createMainObjectsIfNotPresent()

        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print(self.applicationDocumentsDirectory.path)

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
        
        //Updates Notification.
        if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            print("++++Changed++++:")
            print("Total items changed: \(updated.count)")
            for itemChanged in updated{
                
                print("itemChanged: \(itemChanged)")
                for (_,item) in itemChanged.changedValues().enumerated(){
                    if let total=item.value as? Set<NSManagedObject> {
                        print("\(item.key): (\(total.count))" )
                    }else{
                        print("\(item.key): (\(item.value))" )
                    }
                }
            }
            print("+++++++++++++++")
        }
        
        //Inserts Notification.
       if let inserted=userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count>0 {
        print("--- INSERTS ---")
        print(inserted)
        print("+++++++++++++++")
        }
        
        //Deletes Notification.
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> , deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }

    }
    
    //TODO
    func createMainObjectsIfNotPresent() {
        
        //Create root items.
        let libRoot = LibraryItem.getRootItem(withName: "Library", inContext: managedObjectContext)
        let tagRoot = LibraryItem.getRootItem(withName: "Tags", inContext: managedObjectContext)
        let lanRoot = LibraryItem.getRootItem(withName: "Languages", inContext: managedObjectContext)
        let collRoot = LibraryItem.getRootItem(withName: "Lists", inContext: managedObjectContext)
        
        //Create Main Library.
        let libPredicate=NSPredicate(format:"name == 'Library' AND isRootItem == FALSE")
        if (LibraryItem.firstWith(predicate: libPredicate, inContext: managedObjectContext)) == nil  {
            let mainItem=LibraryItem.init(inMOC: managedObjectContext, andName: "Library", isRoot: false)
            mainItem?.libraryType=LibraryType.mainLibrary.rawValue
            mainItem?.sortingOrder="0"
        }
        
        //Create Fav item.
        let favPredicate=NSPredicate(format: "name == 'Favorites' AND isRootItem == FALSE")
        if (LibraryItem.firstWith(predicate: favPredicate, inContext: managedObjectContext)) == nil {
            let favItem=LibraryItem.init(inMOC: managedObjectContext, andName: "Favorites", isRoot: false)
            favItem?.libraryType=LibraryType.favorites.rawValue
            favItem?.sortingOrder="1"
        }
        
        //Create Tags
        ["Love", "Inspirational", "Wow", "Brainer", "Cerebral"].forEach({
            _=Tag.firstOrCreate(inContext: managedObjectContext, withAttributes: ["name":$0])
        })
       
        //Create Languages:
        ["Spanish", "English", "French", "German", "Mandarin"].forEach({
            _=Language.firstOrCreate(inContext: managedObjectContext, withAttributes: ["name":$0])
        })
        
        //create Lists:
        ["Top 25", "For Work", "From Movies", "In songs", "Crazy"].forEach({
            _=QuoteList.firstOrCreate(inContext: managedObjectContext, withAttributes: ["name":$0])
        })
        
        do{
            try self.managedObjectContext.save()
        }
        catch{
            print(error.localizedDescription)
        }
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


