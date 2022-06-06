//
//  AsobiApp.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI

@main
struct AsobiApp: App {
    let persistenceController = PersistenceController.shared

    // At top level for keyboard commands
    @StateObject var webModel: WebViewModel = .init()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(webModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            CommandGroup(after: .textEditing) {
                Divider()

                Button("Find in Page") {
                    webModel.showFindInPage.toggle()
                }.keyboardShortcut("f")
            }

            CommandGroup(after: .windowSize) {
                Divider()

                Button("Zoom in") {
                    let currentZoomScale = webModel.webView.scrollView.zoomScale
                    webModel.webView.scrollView.zoomScale = currentZoomScale + 0.1
                }
                .keyboardShortcut("+", modifiers: [.command, .shift])

                Button("Zoom out") {
                    let currentZoomScale = webModel.webView.scrollView.zoomScale
                    webModel.webView.scrollView.zoomScale = currentZoomScale - 0.1
                }
                .keyboardShortcut("-", modifiers: [.command, .shift])
            }
        }
    }
}
