//
//  HistoryEntry+CoreDataProperties.swift
//  Asobi
//
//  Created by Brian Dashore on 11/9/21.
//
//

import Foundation
import CoreData


extension HistoryEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryEntry> {
        return NSFetchRequest<HistoryEntry>(entityName: "HistoryEntry")
    }

    @NSManaged public var name: String?
    @NSManaged public var timestamp: Double
    @NSManaged public var url: String?
    @NSManaged public var parentHistory: History?

}

extension HistoryEntry : Identifiable {

}
