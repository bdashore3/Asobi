//
//  AsobiApp.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import Introspect
import SwiftUI

@main
struct AsobiApp: App {
    let persistenceController = PersistenceController.shared

    // At top level for keyboard commands
    @StateObject var webModel: WebViewModel = .init()
    @StateObject var navModel: NavigationViewModel = .init()

    // At top level for scenePhase if needed
    @StateObject var rootViewController: AsobiRootViewController = .init(rootViewController: nil, style: .default)

    @AppStorage("browserModeEnabled") var browserModeEnabled = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .introspectViewController { viewController in
                    let window = viewController.view.window
                    guard let rootViewController = window?.rootViewController else { return }
                    self.rootViewController.rootViewController = rootViewController
                    self.rootViewController.ignoreDarkMode = true

                    window?.rootViewController = self.rootViewController
                }
                .environmentObject(webModel)
                .environmentObject(navModel)
                .environmentObject(rootViewController)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            CommandGroup(after: .textEditing) {
                Divider()

                Button("Find in page") {
                    navModel.currentPillView = .findInPage
                }.keyboardShortcut("f", modifiers: [.command, .shift])

                if browserModeEnabled {
                    Button("Show URL bar") {
                        navModel.currentPillView = .urlBar
                    }.keyboardShortcut("u", modifiers: [.command, .shift])
                }
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
