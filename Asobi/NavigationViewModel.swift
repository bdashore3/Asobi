//
//  NavigationViewModel.swift
//  Asobi
//
//  Created by Brian Dashore on 10/25/21.
//

import LocalAuthentication
import SwiftUI

@MainActor
class NavigationViewModel: ObservableObject {
    enum SheetType: Identifiable {
        var id: Int {
            hashValue
        }

        case settings
        case library
        case bookmarkEditing
    }

    enum AuthAlertType: Identifiable, Hashable {
        var id: Self {
            self
        }

        case cancelled
        case missing
        case error(localizedDescription: String)
    }

    @AppStorage("forceSecurityCredentials") var forceSecurityCredentials = false

    @Published var currentSheet: SheetType?
    @Published var isKeyboardShowing = false
    @Published var showNavigationBar = true
    @Published var isUnlocked = true
    @Published var authErrorAlert: AuthAlertType?

    init() {
        if forceSecurityCredentials {
            isUnlocked = false
        }
    }

    func authenticateOnStartup() async {
        let context = LAContext()
        var error: NSError?

        // Can we authenticate?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authentication is required to access Asobi"

            do {
                let result = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)

                isUnlocked = result
            } catch {
                let error = error as NSError

                // The MainActor attribute doesn't fire here, so manually call it to run UI updates
                if error.code == -2 {
                    await MainActor.run {
                        authErrorAlert = .cancelled
                    }
                } else {
                    await MainActor.run {
                        authErrorAlert = .error(localizedDescription: error.localizedDescription)
                    }
                }
            }
        } else {
            // There's no authentication methods, so unlock anyway, show an error, and turn off the setting
            authErrorAlert = .missing

            isUnlocked = true
            UserDefaults.standard.set(false, forKey: "forceSecurityCredentials")
        }
    }

    // Checks if a user has an authentication method
    func authenticationPresent() -> Bool {
        let context = LAContext()
        var error: NSError?

        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
}
