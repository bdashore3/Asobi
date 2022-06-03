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

    @StateObject var webModel: WebViewModel = .init()
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

    // TEMP: Remove in next Asobi version
    @State private var showHistoryRepairedAlert = false
    @State private var repairedHistoryAmount = 0

    var body: some View {
        ZStack {
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
                        if #available(iOS 15.0, *), UIDevice.current.deviceType != .mac {
                            LibraryView(currentUrl: webModel.webView.url?.absoluteString ?? "No URL found")
                        } else {
                            LibraryView(currentUrl: webModel.webView.url?.absoluteString ?? "No URL found")
                                .environment(\.managedObjectContext, managedObjectContext)
                                .environmentObject(navModel)
                        }
                    case .settings:
                        if #available(iOS 15.0, *), UIDevice.current.deviceType != .mac {
                            SettingsView()
                        } else {
                            SettingsView()
                                .environment(\.managedObjectContext, managedObjectContext)
                                .environmentObject(navModel)
                        }
                    case .bookmarkEditing:
                        if #available(iOS 15.0, *), UIDevice.current.deviceType != .mac {
                            EditBookmarkView(bookmark: .constant(nil))
                        } else {
                            EditBookmarkView(bookmark: .constant(nil))
                                .environment(\.managedObjectContext, managedObjectContext)
                                .environmentObject(navModel)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    withAnimation(.easeIn(duration: 0.15)) {
                        navModel.blurRadius = 0
                    }

                    PersistenceController.shared.save()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    if blurInRecents, UIDevice.current.deviceType != .mac {
                        navModel.blurRadius = 15
                    }

                    PersistenceController.shared.save()
                }
                .blur(radius: navModel.blurRadius)
                .overlay {
                    AuthOverlayView()
                }
                .environmentObject(webModel)
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

                    // TEMP: Remove in next Asobi version
                    if !UserDefaults.standard.bool(forKey: "firstLaunchRepairHistory") {
                        repairedHistoryAmount = webModel.repairZombieHistory()
                        showHistoryRepairedAlert.toggle()
                        debugPrint("History repair on firstRun has been executed")
                        UserDefaults.standard.set(true, forKey: "firstLaunchRepairHistory")
                    }
                }
                // TEMP: Remove in next Asobi version
                .alert(isPresented: $showHistoryRepairedAlert) {
                    return Alert(
                        title: Text("History repair complete"),
                        message: Text("A bug was recently fixed regarding browser history and Asobi has fixed the issues. \n\n" +
                                      "A total of \(repairedHistoryAmount) entries have been repaired. This will not show up again. \n\n" +
                                      "If you still have problems, click the repair history button in library."),
                        dismissButton: .default(Text("OK"))
                    )
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
