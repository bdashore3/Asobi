//
//  HistoryActionView.swift
//  Asobi
//
//  Created by Brian Dashore on 11/13/21.
//

import SwiftUI

struct HistoryActionView: View {
    enum HistoryAlertType: Identifiable {
        var id: Int {
            hashValue
        }

        case warn
        case error
        case success
    }

    @State var labelText: String

    @State private var currentHistoryAlert: HistoryAlertType?
    @State private var showWarnAlert = false
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false

    @State private var showActionSheet = false
    @State private var historyDeleteRange: HistoryDeleteRange = .day
    @State private var successAlertRange: String = ""
    @State private var errorMessage: String?

    var body: some View {
        Button {
            showActionSheet.toggle()
        } label: {
            Text(labelText)
                .foregroundColor(.red)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Clear browsing data"),
                message: Text("This will delete your browsing history! Be careful."),
                buttons: [
                    .destructive(Text("Past day")) {
                        historyDeleteRange = .day
                        successAlertRange = "day"
                        showWarnAlert.toggle()
                    },
                    .destructive(Text("Past week")) {
                        historyDeleteRange = .week
                        successAlertRange = "week"
                        showWarnAlert.toggle()
                    },
                    .destructive(Text("Past 4 weeks")) {
                        historyDeleteRange = .month
                        successAlertRange = "4 weeks"
                        showWarnAlert.toggle()
                    },
                    .destructive(Text("All time")) {
                        historyDeleteRange = .allTime
                        showWarnAlert.toggle()
                    },
                    .cancel()
                ]
            )
        }
        .alert(item: $currentHistoryAlert) { alert in
            switch alert {
            case .warn:
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("Deleting browser history is an irreversible action!"),
                    primaryButton: .destructive(Text("Yes")) {
                        do {
                            try PersistenceController.shared.batchDeleteHistory(range: historyDeleteRange)
                            currentHistoryAlert = .success
                        } catch {
                            errorMessage = error.localizedDescription
                            currentHistoryAlert = .error
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .error:
                return Alert(
                    title: Text("Error when clearing data!"),
                    message: Text(errorMessage ?? "This alert popped up by accident, send feedback to the dev."),
                    dismissButton: .default(Text("OK"))
                )
            case .success:
                return Alert(
                    title: Text("Success!"),
                    message: Text("Your browsing data \(successAlertRange.isEmpty ? "" : "from the past \(successAlertRange)") has been cleared"),
                    dismissButton: .default(Text("OK")) {
                        successAlertRange = ""
                    }
                )
            }
        }
    }
}

struct HistoryActionView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryActionView(labelText: "Clear")
    }
}
