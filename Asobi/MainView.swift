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
                .overlay {
                    AuthOverlayView()
                }
                .environmentObject(navModel)
                .onAppear {
                    if forceSecurityCredentials {
                        Task {
                            await navModel.authenticateOnStartup()
                        }
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
