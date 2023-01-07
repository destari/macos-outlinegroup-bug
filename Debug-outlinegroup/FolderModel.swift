//
//  FolderModel.swift
//  Debug-outlinegroup
//
//  Created by Eric Anderson on 1/6/23.
//

import Foundation
import CoreData

extension Folder {
    
    class func newFolder(name: String = "New Folder", icon: String = "folder.fill") -> Folder {
        let viewContext = PersistenceController.shared.viewContext
        let folder = Folder(context: viewContext)
        
        folder.id_ = UUID().uuidString
        folder.name_ = name
        folder.icon_ = icon
        
        
        return folder
    }
    
    class func fetchAll() -> [Folder] {
        let viewContext = PersistenceController.shared.viewContext
        
        let controller: NSFetchedResultsController<Folder>
        
        
        let folderFR: NSFetchRequest<Folder> = Folder.fetchRequest()
        folderFR.sortDescriptors = [NSSortDescriptor(keyPath: \Folder.name_, ascending: false)]
        controller = NSFetchedResultsController(fetchRequest: folderFR,
                                                managedObjectContext: viewContext,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
        
        // Initial fetch to populate todos array
        //        ideasFRC.delegate = self
        try? controller.performFetch()
        
        var folders = controller.fetchedObjects
        if folders == nil {
            folders = []
        }
        
        return folders!
    }
    
    class func fetchTopLevel() -> [Folder] {
        let all = fetchAll()
        
        return all.filter { $0.parent == nil }
    }
    
    class func object(withID id: String) -> Folder? {
        return object(id: id, context: PersistenceController.shared.viewContext) as Folder?
    }
    
    class func allObjects() -> [Folder]? {
        return allObjects(context: PersistenceController.shared.viewContext) as! [Folder]?
    }
    
    class func Preview() -> Folder {
        let preview = newFolder(name: "Preview Folder", icon: "folder")
        
        return preview
    }
    
    
    func delete() {
        PersistenceController.shared.viewContext.delete(self)
        Task {
            await MyModel.shared.save()
        }
    }
    
    
    func save() {
        Task {
            await MyModel.shared.save()
        }
    }
    
    public var id: String {
        get { id_ ?? "No UUID" }
        set { id_ = newValue }
    }
    
    public var name: String {
        get { name_ ?? "New Folder" }
        set { name_ = newValue }
    }
    
    public var icon: String {
        get { icon_ ?? "folder" }
        set { icon_ = newValue }
    }
    
    public var subFolders: [Folder]? {
        if children == nil { return nil }
        if children!.count == 0 { return nil }
        return self.children!.allObjects as! [Folder]?
    }
}




extension NSManagedObject {
    // makes it easy to count NSManagedObjects in a given context.  useful during
    // app development.  used in Item.count() and Location.count() in this app
    class func count(context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: Self.description())
        do {
            let result = try context.count(for: fetchRequest)
            return result
        } catch let error as NSError {
            NSLog("Error counting NSManagedObjects \(Self.description()): \(error.localizedDescription), \(error.userInfo)")
        }
        return 0
    }
    
    // simple way to get all objects
    class func allObjects(context: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: Self.description())
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            NSLog("Error fetching NSManagedObjects \(Self.description()): \(error.localizedDescription), \(error.userInfo)")
        }
        return []
    }
    
    // finds an NSManagedObject with the given UUID (there should only be one, really)
    class func object(id: String, context: NSManagedObjectContext) -> Self? {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: Self.description())
        
        if id == "" { return nil }
        
        fetchRequest.predicate = NSPredicate(format: "id_ == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch let error as NSError {
            NSLog("Error fetching NSManagedObjects \(Self.description()): \(error.localizedDescription), \(error.userInfo)")
        }
        return nil
    }
}
