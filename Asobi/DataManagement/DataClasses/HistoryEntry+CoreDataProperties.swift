//
//  HistoryEntry+CoreDataProperties.swift
//  Asobi
//
//  Created by Brian Dashore on 11/9/21.
//
//

import CoreData
import Foundation

public extension HistoryEntry {
    @nonobjc class func fetchRequest() -> NSFetchRequest<HistoryEntry> {
        NSFetchRequest<HistoryEntry>(entityName: "HistoryEntry")
    }

    @NSManaged var name: String?
    @NSManaged var timestamp: Double
    @NSManaged var url: String?
    @NSManaged var parentHistory: History?
}

extension HistoryEntry: Identifiable {}
