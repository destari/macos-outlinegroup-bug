//
//  Model.swift
//  Debug-outlinegroup
//
//  Created by Eric Anderson on 1/6/23.
//

import Foundation
import CoreData

struct SidebarSelection: Hashable, Identifiable {
    var selectionType: SelectionType = .fixed
    var selectedId: String = ""
    
    enum SelectionType: String {
        case fixed
        case folders
        case tags
    }
    
    var id: String {
        return selectionType.rawValue + "-" + selectedId
    }
}

@MainActor
class MyModel: ObservableObject {
    static let shared = MyModel()
    
    @Published var folders: [Folder]
    @Published var sidebarSelection: SidebarSelection
    
    init() {
        folders = []
        sidebarSelection = SidebarSelection(selectionType: .fixed, selectedId: "all")
        
        updateFolders()
    }
    
    func updateFolders() {
        folders = Folder.fetchTopLevel()
    }
    
    func save() {
        let viewContext = PersistenceController.shared.viewContext
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        updateFolders()
    }
}


