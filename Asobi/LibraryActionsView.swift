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

        case cookies
        case success
        case error
    }

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var downloadManager: DownloadManager

    @Binding var currentUrl: String
    @State private var isCopiedButton = false
    @State private var currentAlert: LibraryActionAlertType?
    @State private var alertText = ""

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

                    Task {
                        try await Task.sleep(seconds: 2)

                        isCopiedButton = false
                    }
                }
            }

            Section {
                Button("Find in page") {
                    webModel.showFindInPage = true
                    navModel.currentSheet = nil
                }

                Button("Save website icon") {
                    Task {
                        do {
                            let urlString = try await webModel.webView.evaluateJavaScript("document.querySelector(`link[rel='apple-touch-icon']`).href") as! String

                            let destination: DownloadRequest.Destination = { _, response in
                                let documentsURL = downloadManager.getFallbackDownloadDirectory()
                                let suggestedName = response.suggestedFilename ?? "favicon"
                                let pathComponent = UIDevice.current.deviceType == .mac ? suggestedName : "favicons/\(suggestedName)"
                                
                                let fileURL = documentsURL.appendingPathComponent(pathComponent)

                                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                            }

                            // Download to favicons folder
                            _ = try await AF.download(URL(string: urlString)!, to: destination).serializingDownloadedFileURL().value

                            alertText = "Image saved in the \(UIDevice.current.deviceType == .mac ? "downloads" : "favicons") folder"
                            currentAlert = .success
                        } catch {
                            alertText = "Cannot get the apple touch icon URL for the website"
                            currentAlert = .error
                        }
                    }
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
    }
}

struct LibraryActionsView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryActionsView(currentUrl: .constant(""))
    }
}
