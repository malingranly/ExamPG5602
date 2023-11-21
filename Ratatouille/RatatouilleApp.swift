//
//  RatatouilleApp.swift
//  Ratatouille
//
//  Created by Malin Granly on 21/11/2023.
//

import SwiftUI

@main
struct RatatouilleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
