//
//  HistoryView.swift
//  Asobi
//
//  Created by Brian Dashore on 11/9/21.
//

import SwiftUI

struct HistoryView: View {
    private var formatter: DateFormatter = .init()

    init() {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
    }

    let backgroundContext = PersistenceController.shared.backgroundContext

    @FetchRequest(
        entity: History.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \History.date, ascending: false)
        ]
    ) var history: FetchedResults<History>

    @State private var historyIndex = 0
    
    func groupedEntries(_ result: FetchedResults<History>) -> [[History]] {
        return Dictionary(grouping: result) { (element: History) in
            element.dateString ?? ""
        }.values.sorted() { $0[0].date ?? Date() > $1[0].date ?? Date() }
    }

    var body: some View {
        List {
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
        .listStyle(.grouped)
    }

    func removeEntry(at offsets: IndexSet, from history: History) {
        for index in offsets {
            let entry = history.entryArray[index]

            history.removeFromEntries(entry)

            if history.entryArray.isEmpty {
                PersistenceController.shared.delete(history, context: backgroundContext)
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
