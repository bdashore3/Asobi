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

    enum PillViewType {
        case urlBar
        case findInPage
    }

    @AppStorage("persistNavigation") private var persistNavigation = false
    @AppStorage("autoHideNavigation") private var autoHideNavigation = false
    @AppStorage("forceSecurityCredentials") private var forceSecurityCredentials = false

    @Published var currentSheet: SheetType?
    @Published var showNavigationBar = true
    @Published var isUnlocked = true
    @Published var authErrorAlert: AuthAlertType?
    @Published var blurRadius: CGFloat = 0
    @Published var currentPillView: PillViewType? {
        didSet {
            // If the button is triggered twice, assume that the user wants to hide the view
            if oldValue == currentPillView {
                currentPillView = nil
            }
        }
    }

    private var autoHideTask: Task<Void, Never>?

    init() {
        if forceSecurityCredentials {
            isUnlocked = false
        }

        // These two settings should never be enabled and run a check on view init
        if persistNavigation, autoHideNavigation {
            UserDefaults.standard.set(false, forKey: "persistNavigation")
            UserDefaults.standard.set(false, forKey: "autoHideNavigation")

            withAnimation {
                showNavigationBar = true
            }
        }
    }

    func toggleNavigationBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showNavigationBar.toggle()
        }
    }

    func setNavigationBar(_ enabled: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            showNavigationBar = enabled
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
                if error.code == -2 || error.code == -4 {
                    await MainActor.run {
                        authErrorAlert = .cancelled
                    }
                } else {
                    await MainActor.run {
                        authErrorAlert = .error(localizedDescription: error.localizedDescription)
                    }
                }

                print("Is unlocked: \(isUnlocked)")
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

    func autoHideNavigationBar() {
        // Marker: If auto hiding is enabled
        if let autoHideTask = autoHideTask {
            autoHideTask.cancel()
        }

        autoHideTask = Task {
            try? await Task.sleep(seconds: 3)

            // If persist navigation is disabled, turn off the navbar
            if !persistNavigation {
                setNavigationBar(false)
            }
        }
    }
}
