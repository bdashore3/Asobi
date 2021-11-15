//
//  History+CoreDataProperties.swift
//  Asobi
//
//  Created by Brian Dashore on 11/9/21.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var entries: NSSet?

    public var entryArray: [HistoryEntry] {
        let entrySet = entries as? Set<HistoryEntry> ?? []
        
        return entrySet.sorted {
            $0.timestamp > $1.timestamp
        }
    }
}

// MARK: Generated accessors for entries
extension History {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: HistoryEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: HistoryEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}

extension History : Identifiable {

}
