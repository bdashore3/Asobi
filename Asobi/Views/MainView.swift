//
//  MainView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/30/22.
//

import Introspect
import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme

    @StateObject var webModel: WebViewModel = .init()
    @StateObject var navModel: NavigationViewModel = .init()
    @StateObject var downloadManager: DownloadManager = .init()
    @StateObject var hostingViewController: HostingViewController = .init(rootViewController: nil, style: .default)

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
                    hostingViewController.rootViewController = rootViewController
                    hostingViewController.ignoreDarkMode = true

                    if statusBarPinType == .hide {
                        hostingViewController.isHidden = true
                    }

                    window?.rootViewController = hostingViewController
                }
                .blur(radius: navModel.isUnlocked ? navModel.blurRadius : 10)
                .onChange(of: scenePhase) { phase in
                    if blurInRecents, UIDevice.current.deviceType != .mac {
                        if phase == .active {
                            withAnimation(.easeIn(duration: 0.15)) {
                                navModel.blurRadius = 0
                            }
                        } else {
                            navModel.blurRadius = 15
                        }
                    }
                }
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
                .onChange(of: colorScheme) { _ in
                    webModel.setStatusbarColor()
                }
                .onChange(of: useDarkTheme || followSystemTheme) { _ in
                    webModel.setStatusbarColor()
                }
                .onChange(of: webModel.backgroundColor) { newColor in
                    hostingViewController.style = newColor.isLight ? .darkContent : .lightContent
                }
                .onChange(of: statusBarPinType) { newPinType in
                    if newPinType == .hide {
                        hostingViewController.isHidden = true
                    } else if newPinType == .pin {
                        hostingViewController.isHidden = false
                    }
                }
                .onChange(of: navModel.showNavigationBar) { showing in
                    if statusBarPinType == .partialHide {
                        hostingViewController.isHidden = !showing
                    }
                }
                .onOpenURL { url in
                    let splitUrl = url.absoluteString.replacingOccurrences(of: "asobi://", with: "")
                    navModel.currentSheet = nil
                    webModel.loadUrl(splitUrl)
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
