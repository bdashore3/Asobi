//
//  HistoryView.swift
//  Asobi
//
//  Created by Brian Dashore on 11/9/21.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    private var formatter: DateFormatter = DateFormatter()

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

    @State private var currentUrl: String?
    @State private var isCopiedButton = false
    @State private var historyIndex = 0
    
    var body: some View {
        List {
            Section(header: "Current URL", footer: "Tap the textbox to copy the URL!") {
                HStack {
                    Text(currentUrl ?? "No URL found")
                        .lineLimit(1)

                    Spacer()
                    
                    Text(isCopiedButton ? "Copied!" : "Copy")
                        .opacity(0.6)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isCopiedButton = true
                    
                    UIPasteboard.general.string = currentUrl
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isCopiedButton = false
                    }
                }
            }

            // Can only use if statements in SwiftUI views. Only show inline button if iOS 14 or below
            if #available(iOS 15, *) {}
            else if UIDevice.current.deviceType == .phone || UIDevice.current.deviceType == .pad {
                HistoryActionView()
            }

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
        .onAppear {
            currentUrl = webModel.webView.url?.absoluteString
        }
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
