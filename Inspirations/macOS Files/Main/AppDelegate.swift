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
    
     func applicationWillFinishLaunching(_ notification: Notification) {
        
        //Register for NSManagedObject Notifications
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self.managedObjectContext)

        //Create Main Items.
        createMainObjectsIfNotPresent()
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print(self.applicationDocumentsDirectory.path)
        
        //Creates .json for ML:
//        let quoteArray:[Quote]=try! Quote.allInContext(self.managedObjectContext)
//        let dictArray=quoteArray.map({$0.textForML()})
//
//        let documentDirectoryUrl = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
//        let fileUrl = documentDirectoryUrl.appendingPathComponent("ML.json")
//        print(fileUrl)
//
//        do {
//            let data = try JSONSerialization.data(withJSONObject: dictArray, options: [])
//            try data.write(to: fileUrl, options: [])
//        } catch {
//            print(error)
//        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack
    
    //NEW:
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Core Data ERD")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
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
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    


    lazy var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("com.apple.toolsQA.CocoaApp_CD")
    }()

    var managedObjectContext:NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        return self.persistentContainer.viewContext
//    }()

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
        //return managedObjectContext.undoManager
    }
    
    //MARK: - Core Data Notifications
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        return
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
    
    //create teh default objects.
    func createMainObjectsIfNotPresent() {
        
        //Create root items.
        _ = LibraryItem.getRootItem(withName: "Library", inContext: managedObjectContext)
        _ = LibraryItem.getRootItem(withName: "Tags", inContext: managedObjectContext)
        _ = LibraryItem.getRootItem(withName: "Languages", inContext: managedObjectContext)
        _ = LibraryItem.getRootItem(withName: "Lists", inContext: managedObjectContext)
        
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
}


/// FELIPE:
/// - Tildes ISO9000
/// - Case insensitive
/// - Random phrase while loading app.
/// - DBPedia Sparqle
/// - Resize and center rows.
/// - Organize files into folders.
