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

    @FetchRequest(
        entity: History.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \History.date, ascending: false)
        ]
    ) var history: FetchedResults<History>

    @State private var historyIndex = 0

    var body: some View {
        List {
            ForEach(history, id: \.self) { history in
                Section(header: Text(formatter.string(from: history.date ?? Date()))) {
                    ForEach(history.entryArray) { entry in
                        ListRowLinkView(text: entry.name ?? "Unknown", link: entry.url ?? "", subText: entry.url)
                    }
                    .onDelete { offsets in
                        self.removeEntry(at: offsets, from: history)
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
                PersistenceController.shared.delete(history)
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
