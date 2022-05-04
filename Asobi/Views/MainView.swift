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

    @StateObject var webModel: WebViewModel = .init()
    @StateObject var navModel: NavigationViewModel = .init()
    @StateObject var downloadManager: DownloadManager = .init()
    @StateObject var rootViewController: AsobiRootViewController = .init(rootViewController: nil, style: .default)

    @AppStorage("forceSecurityCredentials") var forceSecurityCredentials = false
    @AppStorage("blurInRecents") var blurInRecents = false
    @AppStorage("useDarkTheme") var useDarkTheme = false
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarBehaviorType = .partialHide

    @State private var blurRadius: CGFloat = 0

    var body: some View {
        ZStack {
            ContentView()
                .introspectViewController { viewController in
                    let window = viewController.view.window
                    guard let rootViewController = window?.rootViewController else { return }
                    self.rootViewController.rootViewController = rootViewController
                    self.rootViewController.ignoreDarkMode = true

                    if statusBarPinType == .hide {
                        self.rootViewController.isHidden = true
                    }

                    window?.rootViewController = self.rootViewController
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
                    let splitUrl = url.absoluteString.replacingOccurrences(of: "asobi://", with: "")
                    navModel.currentSheet = nil
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
                        rootViewController.isHidden = true
                    } else if newPinType == .pin {
                        rootViewController.isHidden = false
                    }
                }
                .onChange(of: navModel.showNavigationBar) { showing in
                    if statusBarPinType == .partialHide {
                        rootViewController.isHidden = !showing
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
