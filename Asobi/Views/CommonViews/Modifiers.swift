//
//  Modifiers.swift
//  Asobi
//
//  Created by Brian Dashore on 12/27/21.
//

import Introspect
import SwiftUI

// All custom view modifiers go here
struct ApplyTheme: ViewModifier {
    @AppStorage("statusBarStyleType") var statusBarStyleType: StatusBarStyleType = .automatic
    @AppStorage("statusBarAccent") var statusBarAccent: Color = .clear

    let colorScheme: String?

    func body(content: Content) -> some View {
        content
            .introspectViewController { UIViewController in
                switch colorScheme {
                case "dark":
                    UIViewController.overrideUserInterfaceStyle = .dark

                    if statusBarStyleType == .theme {
                        statusBarAccent = .black
                    }
                case "light":
                    UIViewController.overrideUserInterfaceStyle = .light

                    if statusBarStyleType == .theme {
                        statusBarAccent = .white
                    }
                default:
                    UIViewController.overrideUserInterfaceStyle = .unspecified

                    if statusBarStyleType == .theme {
                        if UITraitCollection.current.userInterfaceStyle == .dark {
                            statusBarAccent = .black
                        } else {
                            statusBarAccent = .white
                        }
                    }
                }
            }
    }
}

struct DisabledAppearance: ViewModifier {
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .opacity(disabled ? 0.5 : 1)
    }
}
