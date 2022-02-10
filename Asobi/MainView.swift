//
//  MainView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/30/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var navModel: NavigationViewModel = .init()

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

            // Prevents interactivity with the ContentView
            if !navModel.isUnlocked {
                Color.gray
                    .opacity(0.2)
            }
        }
        .environmentObject(navModel)
        .onAppear {
            if forceSecurityCredentials {
                Task {
                    await navModel.authenticateOnStartup()
                }
            }
        }
        .alert(item: $navModel.authErrorAlert) { alert in
            switch alert {
            case .cancelled:
                return Alert(
                    title: Text("Authentication error"),
                    message: Text("The person using Asobi turned on authentication in settings and auth was forcibly cancelled. \n\nYou can retry if this was a mistake."),
                    primaryButton: .default(Text("Retry")) {
                        Task {
                            await navModel.authenticateOnStartup()
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .missing:
                return Alert(
                    title: Text("Authentication error"),
                    message: Text("It looks like your authentication was turned off, so Asobi automatically unlocked itself. \n\nPlease re-enable an iOS or macOS passcode and turn on the authentication toggle in Asobi's settings to re-enable this feature."),
                    dismissButton: .default(Text("OK"))
                )
            case let .error(localizedDescription: localizedDescription):
                return Alert(
                    title: Text("Authentication error"),
                    message: Text("Unhandled exception, the description is posted below: \n\n\(localizedDescription)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
