//
//  Modifiers.swift
//  Asobi
//
//  Created by Brian Dashore on 12/27/21.
//

import SwiftUI
import Introspect

// All custom view modifiers go here
struct ApplyTheme: ViewModifier {
    let colorScheme: String?

    func body(content: Content) -> some View {
        content
            .introspectViewController { UIViewController in
                switch colorScheme {
                case "dark": UIViewController.overrideUserInterfaceStyle = .dark
                case "light": UIViewController.overrideUserInterfaceStyle = .light
                default: UIViewController.overrideUserInterfaceStyle = .unspecified
                }
            }
    }
}
