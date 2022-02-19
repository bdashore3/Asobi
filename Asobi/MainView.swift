//
//  MainView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/30/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var webModel: WebViewModel = .init()
    @StateObject var navModel: NavigationViewModel = .init()
    @StateObject var downloadManager: DownloadManager = .init()

    @AppStorage("forceSecurityCredentials") var forceSecurityCredentials = false
    @AppStorage("blurInRecents") var blurInRecents = false

    @State private var blurRadius: CGFloat = 0

    var body: some View {
        ZStack {
            ContentView()
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
