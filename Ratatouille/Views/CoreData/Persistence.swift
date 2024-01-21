//
//  Persistence.swift
//  Ratatouille

import CoreData


class PersistenceController {
    /// Variables
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    /// Init
    init() {
        container = NSPersistentContainer(name: "Ratatouille")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
