//
//  PersistenceController.swift
//  Asobi
//
//  Created by Brian Dashore on 10/13/21.
//

import CoreData

enum HistoryDeleteRange {
    case day
    case week
    case month
    case allTime
}

enum HistoryDeleteError: Error {
    case noDate(String)
    case unknown(String)
}

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

        container.loadPersistentStores { _, error in
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

    func getHistoryPredicate(range: HistoryDeleteRange) -> NSPredicate? {
        if range == .allTime {
            return nil
        }

        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0

        guard let today = Calendar.current.date(from: components) else {
            return nil
        }

        var offsetComponents = DateComponents(day: 1)
        guard let tomorrow = Calendar.current.date(byAdding: offsetComponents, to: today) else {
            return nil
        }

        switch range {
        case .week:
            offsetComponents.day = -7
        case .month:
            offsetComponents.day = -28
        default:
            break
        }

        guard var offsetDate = Calendar.current.date(byAdding: offsetComponents, to: today) else {
            return nil
        }

        if TimeZone.current.isDaylightSavingTime(for: offsetDate) {
            offsetDate = offsetDate.addingTimeInterval(3600)
        }

        let predicate = NSPredicate(format: "date >= %@ && date < %@", range == .day ? today as NSDate : offsetDate as NSDate, tomorrow as NSDate)

        return predicate
    }

    // Possibly change this to a default batchDelete function in the future
    func batchDeleteHistory(range: HistoryDeleteRange) throws {
        let context = container.viewContext
        let predicate = getHistoryPredicate(range: range)

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")

        if let predicate = predicate {
            fetchRequest.predicate = predicate
        } else if range != .allTime {
            throw HistoryDeleteError.noDate("No history date range was provided and you weren't trying to clear everything! Try relaunching the app?")
        }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.executeAndMergeChanges(using: deleteRequest)
        } catch {
            throw HistoryDeleteError.unknown(error.localizedDescription)
        }
    }
}
