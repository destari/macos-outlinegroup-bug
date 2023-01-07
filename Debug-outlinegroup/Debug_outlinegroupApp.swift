//
//  Debug_outlinegroupApp.swift
//  Debug-outlinegroup
//
//  Created by Eric Anderson on 1/6/23.
//

import SwiftUI

@main
struct Debug_outlinegroupApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
