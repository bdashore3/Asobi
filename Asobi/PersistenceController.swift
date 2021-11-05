//
//  PersistenceController.swift
//  Asobi
//
//  Created by Brian Dashore on 10/13/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Coredata storage
    let container: NSPersistentContainer

    // Coredata load
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AsobiDB")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint("Error in CoreData saving! \(error.localizedDescription)")
            }
        }
    }

    func delete(_ object: NSManagedObject) {
        let context = container.viewContext
        context.delete(object)
        
        save()
    }
}
