//
//  HistoryView.swift
//  Asobi
//
//  Created by Brian Dashore on 11/9/21.
//

import SwiftUI

struct HistoryView: View {
    private var formatter: DateFormatter = .init()

    let backgroundContext = PersistenceController.shared.backgroundContext

    var history: FetchedResults<History>

    init(history: FetchedResults<History>) {
        self.history = history
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
    }

    var body: some View {
        List {
            if !history.isEmpty {
                ForEach(groupedEntries(history), id: \.self) { (section: [History]) in
                    Section(header: Text(formatter.string(from: section[0].date ?? Date()))) {
                        ForEach(section, id: \.self) { history in
                            ForEach(history.entryArray) { entry in
                                ListRowLinkView(text: entry.name ?? "Unknown", link: entry.url ?? "", subText: entry.url)
                            }
                            .onDelete { offsets in
                                self.removeEntry(at: offsets, from: history)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
    }

    func groupedEntries(_ result: FetchedResults<History>) -> [[History]] {
        Dictionary(grouping: result) { (element: History) in
            element.dateString ?? ""
        }.values.sorted { $0[0].date ?? Date() > $1[0].date ?? Date() }
    }

    func removeEntry(at offsets: IndexSet, from history: History) {
        for index in offsets {
            if let entry = history.entryArray[safe: index] {
                history.removeFromEntries(entry)
                PersistenceController.shared.delete(entry, context: backgroundContext)
            }

            if history.entryArray.isEmpty {
                PersistenceController.shared.delete(history, context: backgroundContext)
            }
        }
    }
}
