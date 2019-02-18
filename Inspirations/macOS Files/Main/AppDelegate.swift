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
        notiCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        

        //Create Main Items.
        createMainObjectsIfNotPresent()
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //print(self.applicationDocumentsDirectory.path)
        
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
        container.viewContext.name = "Main Context"
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
            print("Will save in ApplicationShouldTerminate")
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
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("com.apple.toolsQA.CocoaApp_CD")
    }()

    var managedObjectContext:NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }
    
    //MARK: - Core Data Notifications
    @objc func managedObjectContextDidSave(notification:NSNotification){
        guard let context = notification.object as? NSManagedObjectContext else {return}
        if context.name == "MultipleImporter"{
            self.managedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
        print("Did Save for \(context.name ?? "")")
    }
    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        //Print if merged from background or bacthUpdated/Delete action
        if let refreshed=userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>{
            //print("Objects refreshed: \(refreshed.first?.changedValues().keys)")
            //Forces refresh on left view and NSFetchedresultsController
            let item=self.managedObjectContext.get(standardItem: .rootMain)
            item.willChangeValue(forKey: "hasLibraryItems")
            item.didChangeValue(forKey: "hasLibraryItems")
        }
        
        //Updates Notification.
        if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            
            print(String(repeating: "+", count: 10)+" CHANGED "+String(repeating: "+", count: 10))
            print("Total items changed: \(updated.count)")
            for itemChanged in updated{
                if let item=itemChanged as? LibraryItem{
                    //Neccesary due to shortcomings of ArrayController.
                    item.belongsToLibraryItem?.willChangeValue(forKey: "hasLibraryItems")
                    item.belongsToLibraryItem?.didChangeValue(forKey: "hasLibraryItems")
                }
                print(itemChanged.className)
                if let item=itemChanged as? Quote, item.changedValues().keys.contains("isfavorite"){
                    print("favorite changed.")
                }
                //itemChanged.willAccessValue(forKey: nil) //Trying to get refreshed in the outlineView but not working.
                //print("itemChanged: \(itemChanged)")
//                for (_,item) in itemChanged.changedValues().enumerated(){
////                    if let total=item.value as? Set<NSManagedObject> {
////                        print("\(item.key): (\(total.count))" )
////                    }else{
////                        print("\(item.key): (\(item.value))" )
////                    }
//                }
            }
        }
        
        //Inserts Notification.
       if let inserted=userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count>0 {
        print(String(repeating: "+", count: 10)+" INSERTS "+String(repeating: "+", count: 10))
        print(inserted.count)
        //print(inserted)
        }
        
        //Deletes Notification.
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> , deletes.count > 0 {
            print(String(repeating: "+", count: 10)+" DELETES "+String(repeating: "+", count: 10))
            print(deletes.count)
            //print(deletes)
        }

    }
    
    /// Create the default objects.
    func createMainObjectsIfNotPresent() {
        
        //Create standard items if they dont exists items.
        LibraryType.standardItems.forEach{
            _=managedObjectContext.get(standardItem: $0)
        }
        if managedObjectContext.hasChanges {
            do{
                try self.managedObjectContext.save()
            }
            catch{
                print(error.localizedDescription)
            }
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
