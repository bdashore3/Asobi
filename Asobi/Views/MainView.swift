//
//  MainView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/30/22.
//

import Introspect
import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var managedObjectContext

    @EnvironmentObject var webModel: WebViewModel

    @StateObject var navModel: NavigationViewModel = .init()
    @StateObject var downloadManager: DownloadManager = .init()
    @StateObject var rootViewController: AsobiRootViewController = .init(rootViewController: nil, style: .default)

    @AppStorage("forceSecurityCredentials") var forceSecurityCredentials = false
    @AppStorage("blurInRecents") var blurInRecents = false
    @AppStorage("useDarkTheme") var useDarkTheme = false
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarBehaviorType = .partialHide
    @AppStorage("grayHomeIndicator") var grayHomeIndicator = false
    @AppStorage("useStatefulBookmarks") var useStatefulBookmarks = false

    @State private var blurRadius: CGFloat = 0

    var body: some View {
        ContentView()
            .introspectViewController { viewController in
                let window = viewController.view.window
                guard let rootViewController = window?.rootViewController else { return }
                self.rootViewController.rootViewController = rootViewController
                self.rootViewController.ignoreDarkMode = true

                if statusBarPinType == .hide {
                    self.rootViewController.statusBarHidden = true
                }

                window?.rootViewController = self.rootViewController
            }
            .sheet(item: $navModel.currentSheet) { item in
                switch item {
                case .library:
                    LibraryView(currentUrl: webModel.webView.url?.absoluteString ?? "No URL found")
                        .environment(\.managedObjectContext, managedObjectContext)
                        .environmentObject(navModel)
                case .settings:
                    SettingsView()
                        .environment(\.managedObjectContext, managedObjectContext)
                        .environmentObject(navModel)
                case .bookmarkEditing:
                    NavigationView {
                        EditBookmarkView()
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                    .environmentObject(navModel)
                }
            }
            .preferredColorScheme(followSystemTheme ? nil : (useDarkTheme ? .dark : .light))
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                withAnimation(.easeIn(duration: 0.15)) {
                    navModel.blurRadius = 0
                }

                PersistenceController.shared.save()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                if blurInRecents, UIDevice.current.deviceType != .mac {
                    navModel.blurRadius = 10
                }

                PersistenceController.shared.save()
            }
            .blur(radius: navModel.isUnlocked ? navModel.blurRadius : 15)
            .overlay {
                if !navModel.isUnlocked {
                    AuthOverlayView()
                }
            }
            .environmentObject(navModel)
            .environmentObject(downloadManager)
            .environmentObject(rootViewController)
            .onAppear {
                if downloadManager.webModel == nil {
                    downloadManager.webModel = webModel
                }

                if forceSecurityCredentials {
                    Task {
                        await navModel.authenticateOnStartup()
                    }
                }
            }
            .onOpenURL { url in
                var splitUrl = url.absoluteString.replacingOccurrences(of: "asobi://", with: "")
                navModel.currentSheet = nil

                if useStatefulBookmarks {
                    let historyRequest = HistoryEntry.fetchRequest()
                    historyRequest.predicate = NSPredicate(format: "url CONTAINS %@", splitUrl)
                    historyRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryEntry.timestamp, ascending: false)]
                    historyRequest.fetchLimit = 1

                    if let entry = try? PersistenceController.shared.backgroundContext.fetch(historyRequest).first, let url = entry.url {
                        splitUrl = url
                    }
                }

                webModel.loadUrl(splitUrl)
            }
            .onChange(of: colorScheme) { _ in
                webModel.setStatusbarColor()
            }
            .onChange(of: useDarkTheme || followSystemTheme) { _ in
                webModel.setStatusbarColor()
            }
            .onChange(of: webModel.backgroundColor) { newColor in
                rootViewController.style = newColor.isLight ? .darkContent : .lightContent
            }
            .onChange(of: statusBarPinType) { newPinType in
                if newPinType == .hide {
                    rootViewController.statusBarHidden = true
                } else if newPinType == .pin {
                    rootViewController.statusBarHidden = false
                }
            }
            .onChange(of: navModel.showNavigationBar) { showing in
                print("Navigation bar showing?: \(showing)")

                if statusBarPinType == .partialHide {
                    rootViewController.statusBarHidden = !showing
                }

                if grayHomeIndicator {
                    rootViewController.grayHomeIndicator = !showing
                }
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
