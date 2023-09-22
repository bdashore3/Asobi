//
//  LibraryActionsView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/5/22.
//

import Alamofire
import SwiftUI

struct LibraryActionsView: View {
    enum LibraryActionAlertType: Identifiable {
        var id: Int {
            hashValue
        }

        case repairHistory
        case cache
        case cookies
        case success
        case error
    }

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var downloadManager: DownloadManager

    @AppStorage("useUrlBar") var useUrlBar = false

    @Binding var currentUrl: String
    @State private var isCopiedButton = false
    @State private var currentAlert: LibraryActionAlertType?
    @State private var alertText = ""
    @State private var showLibraryActionProgress = false

    var body: some View {
        Form {
            Section(
                header: Text("Current URL"),
                footer: Text("Tap the textbox to copy the URL!")
            ) {
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

                    Task {
                        try await Task.sleep(seconds: 2)

                        isCopiedButton = false
                    }
                }
            }

            Section {
                Button("Refresh page") {
                    webModel.webView.reload()
                    navModel.currentSheet = nil
                }

                Button("Find in page") {
                    navModel.currentPillView = .findInPage
                    navModel.currentSheet = nil
                }

                if useUrlBar {
                    Button("Show URL bar") {
                        navModel.currentPillView = .urlBar
                        navModel.currentSheet = nil
                    }

                    Button("Go to homepage") {
                        webModel.goHome()
                    }
                }

                // Group all buttons tied to one alert
                Group {
                    Button("Save website icon") {
                        Task {
                            do {
                                try await downloadManager.downloadFavicon()

                                alertText = "Image saved in the \(UIDevice.current.deviceType == .mac ? "downloads" : "favicons") folder"
                                currentAlert = .success
                            } catch {
                                alertText = "Cannot get the apple touch icon URL for the website"
                                currentAlert = .error
                            }
                        }
                    }

                    Button("Repair history") {
                        currentAlert = .repairHistory
                    }

                    Button("Clear all cookies") {
                        currentAlert = .cookies
                    }
                    .accentColor(.red)

                    Button("Clear browser cache") {
                        currentAlert = .cache
                    }
                    .accentColor(.red)
                }
                .alert(item: $currentAlert) { alert in
                    switch alert {
                    case .repairHistory:
                        return Alert(
                            title: Text("Are you sure?"),
                            message: Text("This will attempt to re-link any leftover (zombie) history entries. Do you want to proceed?"),
                            primaryButton: .default(Text("Yes")) {
                                showLibraryActionProgress = true
                                let repairedCount = webModel.repairZombieHistory()
                                showLibraryActionProgress = false

                                alertText = "A total of \(repairedCount) history entries have been re-associated. \n\nIf you still have problems, consider clearing browsing data."
                                currentAlert = .success
                            },
                            secondaryButton: .cancel()
                        )
                    case .cache:
                        return Alert(
                            title: Text("Are you sure?"),
                            message: Text("Clearing browser cache is an irreversible action!"),
                            primaryButton: .destructive(Text("Yes")) {
                                Task {
                                    await webModel.clearCache()

                                    alertText = "Browser cache has been cleared"
                                    currentAlert = .success
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    case .cookies:
                        return Alert(
                            title: Text("Are you sure?"),
                            message: Text("Clearing cookies is an irreversible action!"),
                            primaryButton: .destructive(Text("Yes")) {
                                Task {
                                    await webModel.clearCookies()

                                    alertText = "Cookies have been cleared"
                                    currentAlert = .success
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    case .success:
                        return Alert(
                            title: Text("Success!"),
                            message: Text(alertText.isEmpty ? "No description given" : alertText),
                            dismissButton: .default(Text("OK")) {
                                alertText = ""
                            }
                        )
                    case .error:
                        return Alert(
                            title: Text("Error!"),
                            message: Text(alertText.isEmpty ? "No description given" : alertText),
                            dismissButton: .default(Text("OK")) {
                                alertText = ""
                            }
                        )
                    }
                }

                HistoryActionView(labelText: "Clear browsing data")
            }
        }
        .overlay {
            if showLibraryActionProgress {
                GroupBox {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)

                        Text("Working...")
                    }
                }
                .shadow(radius: 10)
            }
        }
    }
}

struct LibraryActionsView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryActionsView(currentUrl: .constant(""))
    }
}
