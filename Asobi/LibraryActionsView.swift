//
//  LibraryActionsView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/5/22.
//

import SwiftUI

struct LibraryActionsView: View {
    enum LibraryActionAlertType: Identifiable {
        var id: Int {
            hashValue
        }

        case success
        case cookies
    }

    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @Binding var currentUrl: String
    @State private var isCopiedButton = false
    @State private var currentAlert: LibraryActionAlertType?

    var body: some View {
        Form {
            Section(header: "Current URL", footer: "Tap the textbox to copy the URL!") {
                HStack {
                    Text(currentUrl)
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

            Section {
                Button("Find in page") {
                    webModel.showFindInPage = true
                    navModel.currentSheet = nil
                }

                Button("Clear all cookies") {
                    currentAlert = .cookies
                }
                .accentColor(.red)
                .alert(item: $currentAlert) { alert in
                    switch alert {
                    case .cookies:
                        return Alert(
                            title: Text("Are you sure?"),
                            message: Text("Clearing cookies is an irreversible action!"),
                            primaryButton: .destructive(Text("Yes")) {
                                Task {
                                    await webModel.clearCookies()
                                    currentAlert = .success
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    case .success:
                        return Alert(
                            title: Text("Success!"),
                            message: Text("The action completed successfully"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }

                HistoryActionView(labelText: "Clear browsing data")
            }
        }
    }
}

struct LibraryActionsView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryActionsView(currentUrl: .constant(""))
    }
}
