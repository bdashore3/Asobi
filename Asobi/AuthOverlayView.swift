//
//  AuthOverlayView.swift
//  Asobi
//
//  Created by Brian Dashore on 2/12/22.
//

import SwiftUI

struct AuthOverlayView: View {
    @EnvironmentObject var navModel: NavigationViewModel
    
    var body: some View {
        // Dummy ZStack for alert presentation
        ZStack {
            if !navModel.isUnlocked {
                Color.gray
                    .opacity(0.2)
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

struct AuthOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        AuthOverlayView()
    }
}
